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
        "/var/lib/docker/volumes/gotify_*"
        "/var/lib/docker/volumes/netbird_*"
        "/var/lib/docker/volumes/nextcloud_*"
        "/var/lib/docker/volumes/resource-planning_*"
        "/var/lib/docker/volumes/rybbit_*"
        "/var/lib/docker/volumes/shlink_*"
        "/var/lib/docker/volumes/wazuh_*"
	"/root/mailcow"
	"/var/lib/docker/volumes/mailcow*"
      ];
      backupSopsFile = ../../secrets/system/lunar.yml;
      
      extraPrepareCommands = ''
	FOLDER="/home/samuel/apps"
	
	$POSTGRES $FOLDER/gotify & 
        $POSTGRES $FOLDER/keycloak &
	$MARIADB /root/mailcow mysql-mailcow DBNAME DBUSER DBPASS &
	$POSTGRES $FOLDER/nextcloud db PG_DB PG_USER &
	$POSTGRES $FOLDER/resource-planning db DJANGO_DB_NAME DJANGO_DB_USER &
	$POSTGRES $FOLDER/rybbit postgres &
        $POSTGRES $FOLDER/shlink db DB_NAME DB_USER &
        wait
      '';
    };
  };
}

