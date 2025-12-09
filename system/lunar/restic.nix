# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

let
  #backupPrepareScript = pkgs.writeShellScript "restic-backup-prepare" ''
  #  export PATH=${lib.makeBinPath [ pkgs.docker pkgs.coreutils pkgs.bash ]}:$PATH
  #
  #  POSTGRES="${pkgs.bash}/bin/bash ${inputs.db_backup_scripts}/postgres_backup.sh"
  #  MARIADB="${pkgs.bash}/bin/bash ${inputs.db_backup_scripts}/mariadb_backup.sh"
  #
  #  # Call your existing script logic
  #  $POSTGRES /home/samuel/apps/AppFlowy postgres &
  #  $POSTGRES /home/samuel/apps/healthchecks db "" "" "" DB_NAME DB_USER &
  #  $POSTGRES /home/samuel/apps/n8n &
  #  $MARIADB /home/samuel/apps/tabby-web db "" "" "" MARIADB_DATABASE MARIADB_USER MARIADB_PASSWORD &
  #  wait
  #'';
in
{
  sops.secrets = let
    sopsFile = ../../secrets/system/lunar.yml;
  in
  {
    backup-password = {
      inherit sopsFile;
    };
    backup-repo = {
      inherit sopsFile;
    };
  };

  services.restic.backups = {
    backup = {
      initialize = true;
      user = "root";
      paths = [
	"/home/samuel"
	"/var/lib/docker/volumes/wazuh_*"
      ];
      exclude = [
	"/home/*/.cache"
	"/home/*/.zsh_history"
      ];
      repositoryFile = config.sops.secrets.backup-repo.path;
      passwordFile = config.sops.secrets.backup-password.path;
      pruneOpts = [
	"--keep-within-hourly 3d"
	"--keep-within-daily 14d"
	"--keep-within-weekly 1m"
	"--keep-within-monthly 1y"
      ];
      #backupPrepareCommand = "${backupPrepareScript}";
      timerConfig = {
	# On 6 o'clock
	OnCalendar = "*-*-* 04:00:00";
	RandomizedDelaySec = "2h";
	# Reschedule times missed cuz of downtime
	Persistent = true;
      };
    };
  };
}

