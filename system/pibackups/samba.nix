# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  shareUser = "samba";
in
{
  sops.secrets.samba-password = {
    sopsFile = ../../secrets/system/pibackups.yml;
  };

  users.groups.${shareUser} = {};

  users.users.${shareUser} = {
    isSystemUser = true;
    group = shareUser;
    home = "/share";
    homeMode = "0755";  # only owner can write; others have no access
    shell = "${pkgs.shadow}/bin/nologin";
    description = "Samba share-only user";
  };

  # Set Samba Password
  system.activationScripts.samba-set-password = {
    deps = [ "users" "setupSecrets" ];
    text = ''
      pw=$(cat ${config.sops.secrets.samba-password.path})
      printf "%s\n%s\n" "$pw" "$pw" \
	| ${pkgs.samba}/bin/smbpasswd -s -a ${shareUser}
    '';
  };


  # Samba (drive shares)
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
	security = "user";
	"invalid users" = [
	  "root"
	];

	"hosts allow" = "192.168.18.0/24 100.85.0.0/16 127.0.0.1 localhost";
	"hosts deny" = "0.0.0.0/0";
	"guest ok" = "no";
      };

      shared = {
	"path" = "/shared";
	"browsable" = "yes";
	"read only" = "no";
	"create mask" = "0644";
	"directory mask" = "0755";
	"valid users" = [
	  shareUser
	];
      };
    };
  };

  # So Windows machines can detect it
  #services.samba-wsdd = {
  #  enable = true;
  #  openFirewall = true;
  #};
}

