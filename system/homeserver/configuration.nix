# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

let
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../configuration.nix
      ../program.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.zsh.shellAliases = {
    "nixeditc" = "nvim ~/dotfiles/system/homeserver/configuration.nix";
    "nixeditp" = "nvim ~/dotfiles/system/homeserver/program.nix";
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
    
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };
}
