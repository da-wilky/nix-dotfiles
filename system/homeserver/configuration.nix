# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, ... }:

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

  #programs.nix-ld.dev.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
  ];

  #environment.variables = pkgs.lib.mkForce {
  #	"NIX_LD_LIBRARY_PATH" = lib.makeLibraryPath [
  #       pkgs.stdenv.cc.cc
  #	  pkgs.openssl
  #        ];
  #      "NIX_LD" = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
  #};

   systemd.services.vscode-server-daemon = {
     description = "VSCode Server Daemon";
     serviceConfig = {
       ExecStart = "${pkgs.vscode}/bin/code tunnel --accept-server-license-terms --name Homeserver";
       #ExecStop = "pkill code";
       Restart = "on-failure";
       User = "samuel";
       Environment = [''"NIX_LD_LIBRARY_PATH=${lib.makeLibraryPath [
          pkgs.stdenv.cc.cc
       ]}"'' ''"NIX_LD=${pkgs.glibc}/lib/ld-linux-x86-64.so.2"''];
     };
     path = [ "/run/current-system/sw" ];
     wantedBy = [ "default.target" ];
     wants = [ "network-online.target" ];
     after = [ "network-online.target" ];
   };
   systemd.services.vscode-server-daemon.enable = true;

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
}
