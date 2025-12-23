# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

let
  backupPrepareScript = pkgs.writeShellScript "restic-backup-prepare" ''
    export PATH=${lib.makeBinPath [ pkgs.docker pkgs.coreutils pkgs.bash ]}:$PATH
  
    POSTGRES="${pkgs.bash}/bin/bash ${inputs.db_backup_scripts}/postgres_backup.sh"
  
    # Call your existing script logic
    $POSTGRES /home/samuel/apps/resource-planning db DJANGO_DB_NAME DJANGO_DB_USER &
    $POSTGRES /home/samuel/apps/shlink db DB_NAME DB_USER &
    $POSTGRES /home/samuel/apps/keycloak &
    wait
  '';
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
	"/var/lib/docker/volumes/resource-planning_*"
	"/var/lib/docker/volumes/shlink_*"
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
      backupPrepareCommand = "${backupPrepareScript}";
      timerConfig = {
	# On 6 o'clock
	OnCalendar = "*-*-* 02:00:00";
	RandomizedDelaySec = "4h";
	# Reschedule times missed cuz of downtime
	Persistent = true;
      };
    };
  };
}

