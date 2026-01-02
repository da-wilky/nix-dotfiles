{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.myModules.resticBackup;

  backupModule = types.submodule {
    options = {
      backupPingName = mkOption {
        type = types.str;
        description = "Name used for healthcheck pings and backup identification";
      };

      paths = mkOption {
        type = types.listOf types.str;
        description = "Paths to backup";
        example = [ "/home/samuel" "/data" ];
      };

      exclude = mkOption {
        type = types.listOf types.str;
        default = [
          "/home/*/.cache"
          "/home/*/.zsh_history"
        ];
        description = "Patterns to exclude from backup";
      };

      backupSopsFile = mkOption {
        type = types.path;
        description = "Sops file containing backup-password and backup-repo secrets";
        example = literalExpression "../../secrets/system/homeserver.yml";
      };

      healthcheckSopsFile = mkOption {
        type = types.path;
        default = ../secrets/func/healthcheck.yml;
        description = "Sops file containing healthcheck-domain and healthcheck-ping-key secrets";
      };

      enablePings = mkOption {
        type = types.bool;
        default = true;
        description = "Enable healthcheck pings for backup start, success, and failure";
      };

      extraPrepareCommands = mkOption {
        type = types.lines;
        default = "";
        description = "Additional commands to run during backup preparation (after ping)";
        example = literalExpression ''
          POSTGRES="''${pkgs.bash}/bin/bash ''${inputs.db_backup_scripts}/postgres_backup.sh"
          $POSTGRES /home/samuel/immich database "" "" "" DB_DATABASE_NAME DB_USERNAME &
          wait
        '';
      };

      pruneOpts = mkOption {
        type = types.listOf types.str;
        default = [
          "--keep-within-hourly 3d"
          "--keep-within-daily 14d"
          "--keep-within-weekly 1m"
          "--keep-within-monthly 1y"
        ];
        description = "Options for pruning old backups";
      };

      timerConfig = mkOption {
        type = types.attrsOf types.str;
        default = {
          OnCalendar = "*-*-* 02:00:00";
          RandomizedDelaySec = "4h";
          Persistent = "true";
        };
        description = "Systemd timer configuration";
      };

      user = mkOption {
        type = types.str;
        default = "root";
        description = "User to run the backup as";
      };
    };
  };
in
{
  options.myModules.resticBackup = mkOption {
    type = types.attrsOf backupModule;
    default = {};
    description = "Restic backup configurations with healthcheck pings";
  };

  config = mkMerge [
    # Sops secrets for all backups
    {
      sops.secrets = mkMerge (
        mapAttrsToList (name: backupCfg: {
          "backup-${name}-password" = {
            sopsFile = backupCfg.backupSopsFile;
            key = "backup-password";
          };
          "backup-${name}-repo" = {
            sopsFile = backupCfg.backupSopsFile;
            key = "backup-repo";
          };
        } // optionalAttrs backupCfg.enablePings {
          "healthcheck-domain" = {
            sopsFile = backupCfg.healthcheckSopsFile;
          };
          "healthcheck-ping-key" = {
            sopsFile = backupCfg.healthcheckSopsFile;
          };
        }) cfg
      );
    }

    # Restic backups configuration
    {
      services.restic.backups = mapAttrs' (name: backupCfg: nameValuePair name {
        initialize = true;
        user = backupCfg.user;
        paths = backupCfg.paths;
        exclude = backupCfg.exclude;
        repositoryFile = config.sops.secrets."backup-${name}-repo".path;
        passwordFile = config.sops.secrets."backup-${name}-password".path;
        pruneOpts = backupCfg.pruneOpts;
        backupPrepareCommand = let
          pingCommands = optionalString backupCfg.enablePings ''
            HEALTHCHECK_DOMAIN=$(cat ${config.sops.secrets.healthcheck-domain.path})
            HEALTHCHECK_KEY=$(cat ${config.sops.secrets.healthcheck-ping-key.path})

            # Notify backup start
            ${pkgs.curl}/bin/curl -m 10 --retry 5 -X POST -H "Content-Type: text/plain" \
              --data "Starting backup for machine: ${backupCfg.backupPingName}" \
              "$HEALTHCHECK_DOMAIN/ping/$HEALTHCHECK_KEY/${backupCfg.backupPingName}/start?create=1"
          '';
          
          backupPrepareScript = pkgs.writeShellScript "restic-backup-${name}-prepare" ''
            export PATH=${lib.makeBinPath [ pkgs.docker pkgs.coreutils pkgs.bash pkgs.curl ]}:$PATH
            POSTGRES="${pkgs.bash}/bin/bash ${inputs.db_backup_scripts}/postgres_backup.sh"
            MARIADB="${pkgs.bash}/bin/bash ${inputs.db_backup_scripts}/mariadb_backup.sh"

            ${pingCommands}

            ${backupCfg.extraPrepareCommands}
          '';
        in "${backupPrepareScript}";
        
        timerConfig = backupCfg.timerConfig;
      }) cfg;
    }

    # Systemd services for success/failure handlers
    {
      systemd.services = mkMerge (
        mapAttrsToList (name: backupCfg: mkIf backupCfg.enablePings {
          "restic-backups-${name}" = {
            onSuccess = [ "restic-backup-${name}-success.service" ];
            onFailure = [ "restic-backup-${name}-failure.service" ];
          };

          "restic-backup-${name}-success" = {
            serviceConfig = {
              Type = "oneshot";
              User = backupCfg.user;
            };
            script = ''
              echo "Restic backup '${name}' completed successfully at $(date)"

              HEALTHCHECK_DOMAIN=$(cat ${config.sops.secrets.healthcheck-domain.path})
              HEALTHCHECK_KEY=$(cat ${config.sops.secrets.healthcheck-ping-key.path})

              ${pkgs.curl}/bin/curl -m 10 --retry 5 -X POST -H "Content-Type: text/plain" \
                --data "Backup completed successfully for machine: ${backupCfg.backupPingName}" \
                "$HEALTHCHECK_DOMAIN/ping/$HEALTHCHECK_KEY/${backupCfg.backupPingName}"
            '';
          };

          "restic-backup-${name}-failure" = {
            serviceConfig = {
              Type = "oneshot";
              User = backupCfg.user;
            };
            script = ''
              echo "Restic backup '${name}' FAILED at $(date)"

              HEALTHCHECK_DOMAIN=$(cat ${config.sops.secrets.healthcheck-domain.path})
              HEALTHCHECK_KEY=$(cat ${config.sops.secrets.healthcheck-ping-key.path})

              ${pkgs.curl}/bin/curl -m 10 --retry 5 -X POST -H "Content-Type: text/plain" \
                --data "Backup FAILED for machine: ${backupCfg.backupPingName}" \
                "$HEALTHCHECK_DOMAIN/ping/$HEALTHCHECK_KEY/${backupCfg.backupPingName}/fail"
            '';
          };
        }) cfg
      );
    }
  ];
}
