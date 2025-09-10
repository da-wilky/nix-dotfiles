# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./my-hardware-configuration.nix
      ./program.nix
      ../configuration.nix
      ../program.nix
      ../firewall-trust-docker.nix
    ];

  programs.zsh.shellAliases = {
    nixupdate = "sudo nixos-rebuild switch --flake ~/dotfiles/#pi5dd";
    nixeditc = "nvim ~/dotfiles/system/pi5dd/configuration.nix";
    nixeditp = "nvim ~/dotfiles/system/pi5dd/program.nix";
    poweroff = "reboot";
  };

  sops.secrets.wireless-config-dd = {
    sopsFile = ../pibackups/secrets.yml;
    restartUnits = [ "wpa_supplicant-wlan0.service" ];
  };

  networking = {
    hostId = "44e41731"; # Needed for zfs
    hostName = "pi5dd"; # Define your hostname.
    # Pick only one of the below networking options.
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      secretsFile = config.sops.secrets.wireless-config-dd.path;
      networks."FRITZiBox 7590".pskRaw = "ext:home_psk";
    };
    #networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [ 22 ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
  };

  security.sudo.wheelNeedsPassword = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}

