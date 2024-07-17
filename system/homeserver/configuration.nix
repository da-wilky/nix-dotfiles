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
      ../configuration.nix
      ../program.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.zsh.shellAliases = {
    nixupdate = "sudo nixos-rebuild switch --flake ~/dotfiles/#homeserver";
    nixeditc = "nvim ~/dotfiles/system/homeserver/configuration.nix";
    nixeditp = "nvim ~/dotfiles/system/homeserver/program.nix";
  };

  #programs.nix-ld.dev.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
  ];

  users.users.fabi = {
    isNormalUser = true;
    description = "Fabius";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFYPJIYpDXdLFLTzp+ftjjA9dgS1jAw2URGM15LTRUzI fabius2001@hotmail.de" ];   
  };

  services.netbird = {
    enable = true;
    tunnels.mine.environment = {
      NB_MANAGEMENT_URL = "https://netbird.swilk.eu";
      NB_SETUP_KEY = "16EBCBC9-0167-47C2-B7BF-C4EAC0BD108F";
    };
  };

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
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
