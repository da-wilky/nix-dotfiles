# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

let
  backupPrepareScript = pkgs.writeShellScript "restic-backup-prepare" ''
    export PATH=${lib.makeBinPath [ pkgs.docker pkgs.coreutils pkgs.bash ]}:$PATH

    POSTGRES="${pkgs.bash}/bin/bash ${inputs.db_backup_scripts}/postgres_backup.sh"

    # Call your existing script logic
    $POSTGRES /home/samuel/immich database "" "" "" DB_DATABASE_NAME DB_USERNAME &
    $POSTGRES /home/samuel/vaultwarden &
    $POSTGRES /home/samuel/mail-archiver postgres "" "" "" "" "" "" mail_archiver &
    $POSTGRES /home/samuel/solidtime database "" "" "" DB_DATABASE DB_USERNAME &
    wait
  '';
in
{
  sops.secrets = let
    sopsFile = ../../secrets/system/pi5dd.yml;
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
	"/data/immich"
	"/data/mails"
	"/data/others"
	"/var/lib/docker/volumes/immich_*"
	"/var/lib/docker/volumes/kimai_*"
	"/var/lib/docker/volumes/solidtime_*"
	"/var/lib/docker/volumes/opnform_*"
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
	OnCalendar = "*-*-* 00:37:00";
	RandomizedDelaySec = "2h";
	# Reschedule times missed cuz of downtime
	Persistent = true;
      };
    };
  };
}

