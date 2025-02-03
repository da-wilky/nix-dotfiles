# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./program.nix
      ./disable-expose-sshd.nix
      ../configuration.nix
      ../program.nix
      ../firewall-trust-docker.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "1blu"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 3478 5349 ];
  networking.firewall.allowedUDPPorts = [ 3478 5349 ];
  networking.firewall.interfaces."wt0" = {
    allowedTCPPorts = [ 3821 ];
  };
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  users.users.samuel.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJdVF0E34V4Ya5xqp3iHRWME1tyTRrGAMkyBC+Mcf2Tg samuel@rs-zap716701-1" ];

  #programs.zsh.enable = true;
  programs.zsh.shellAliases = {
    nixupdate = "sudo nixos-rebuild switch --flake ~/dotfiles/#blu";
    nixeditc = "nvim ~/dotfiles/system/blu/configuration.nix";
    nixeditp = "nvim ~/dotfiles/system/blu/program.nix";
  };

  services.openssh.ports = [ 3821 ];

  sops.secrets.backup-password-1blu = {
    sopsFile = ../../secrets.yml;
  };

  services.restic.backups = {
    serverbackup = {
      initialize = true;
      user = "root";
      paths = [
	"/home/samuel"
	"/var/lib/docker/volumes/coolify-*"
	"/var/lib/docker/volumes/icinga_*"
	"/var/lib/docker/volumes/netbird_*"
	"/var/lib/docker/volumes/tabby-web_*"
	"/var/lib/docker/volumes/traefik-*"
      ];
      exclude = [
	"/home/*/.cache"
	"/home/*/.zsh_history"
      ];
      repository = "sftp:pibackups:/data/backups/1blu";
      passwordFile = config.sops.secrets.backup-password-1blu.path;
      pruneOpts = [
	"--keep-within-hourly 3d"
	"--keep-within-daily 14d"
	"--keep-within-weekly 1m"
	"--keep-within-monthly 1y"
      ];
      timerConfig = {
	# On 6 o'clock
	OnCalendar = "*-*-* 06:00:00";
	# Reschedule times missed cuz of downtime
	Persistent = true;
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
