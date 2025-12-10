# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, ... }:

let
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./program.nix
      ./restic.nix
      ../configuration.nix
      ../program.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  fileSystems."/data" =
    { device = "/dev/disk/by-uuid/01d7af1a-c6dc-451c-a7b3-36797c2ffe15";
      fsType = "ext4";
    };

  programs.zsh.shellAliases = {
    nixupdate = "sudo nixos-rebuild switch --flake ~/dotfiles/#homeserver";
    nixeditc = "nvim ~/dotfiles/system/homeserver/configuration.nix";
    nixeditp = "nvim ~/dotfiles/system/homeserver/program.nix";
  };

  networking = {
    hostName = "homeserver"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    
    # Enable networking
    networkmanager.enable = true;
    
    # Open ports in the firewall.
    firewall.allowedTCPPorts = [ 22 3000 ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;

    # Wake On Lan - needs BIOS setting enabled
    interfaces.enp1s0.wakeOnLan.enable = true;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
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
