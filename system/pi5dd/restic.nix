# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  myModules.resticBackup = {
    backup = {
      backupPingName = "pi5dd";
      paths = [
        "/home/samuel"
        "/data/immich"
        "/data/mails"
        "/data/others"
        "/var/lib/docker/volumes/immich_*"
        "/var/lib/docker/volumes/kimai_*"
        "/var/lib/docker/volumes/solidtime_*"
        "/var/lib/docker/volumes/opnform_*"
        "/var/lib/docker/volumes/timetracker_*"
      ];
      backupSopsFile = ../../secrets/system/pi5dd.yml;
      
      extraPrepareCommands = ''
        $POSTGRES /home/samuel/immich database DB_DATABASE_NAME DB_USERNAME &
        $POSTGRES /home/samuel/vaultwarden &
        $POSTGRES /home/samuel/mail-archiver postgres "" "" /data/mails/mail-archiver/db_backup &
        $POSTGRES /home/samuel/solidtime database DB_DATABASE DB_USERNAME &
        $POSTGRES /home/samuel/TimeTracker &
        wait
      '';
    };
  };
}

