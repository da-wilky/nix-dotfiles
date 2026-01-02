# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  myModules.resticBackup = {
    backup = {
      backupPingName = "homeserver";
      paths = [ "/home/samuel" "/data" ];
      backupSopsFile = ../../secrets/system/homeserver.yml;

      # Optional: Add database backup commands
      # extraPrepareCommands = ''
      #   $POSTGRES /home/samuel/immich database "" "" "" DB_DATABASE_NAME DB_USERNAME &
      #   $POSTGRES /home/samuel/vaultwarden &
      #   $POSTGRES /home/samuel/mail-archiver postgres "" "" "" "" "" "" mail_archiver &
      #   $POSTGRES /home/samuel/solidtime database "" "" "" DB_DATABASE DB_USERNAME &
      #   wait
      # '';
    };
  };
}

