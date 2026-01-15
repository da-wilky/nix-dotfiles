# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  myModules.resticBackup = {
    backup = {
      backupPingName = "lunar";
      paths = [
        "/home/samuel"
        "/var/lib/docker/volumes/wazuh_*"
        "/var/lib/docker/volumes/resource-planning_*"
        "/var/lib/docker/volumes/shlink_*"
        "/var/lib/docker/volumes/netbird_*"
      ];
      backupSopsFile = ../../secrets/system/lunar.yml;
      
      extraPrepareCommands = ''
	FOLDER="/home/samuel/apps"
	
	$POSTGRES $FOLDER/resource-planning db DJANGO_DB_NAME DJANGO_DB_USER &
        $POSTGRES $FOLDER/shlink db DB_NAME DB_USER &
        $POSTGRES $FOLDER/keycloak &
        wait
      '';
    };
  };
}

