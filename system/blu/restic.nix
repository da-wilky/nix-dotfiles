# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  myModules.resticBackup = {
    backup = {
      backupPingName = "1blu";
      paths = [
        "/home/samuel"
        "/var/lib/docker/volumes/traefik-*"
        "/var/lib/docker/volumes/appflowy_*"
        "/var/lib/docker/volumes/tabby-web_*"
      ];
      backupSopsFile = ../../secrets/system/1blu.yml;
      
      extraPrepareCommands = ''
        $POSTGRES /home/samuel/apps/AppFlowy postgres &
        $POSTGRES /home/samuel/apps/healthchecks db DB_NAME DB_USER &
        $POSTGRES /home/samuel/apps/n8n &
        $MARIADB /home/samuel/apps/tabby-web db MARIADB_DATABASE MARIADB_USER MARIADB_PASSWORD &
        wait
      '';
    };
  };
}

