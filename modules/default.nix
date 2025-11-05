{ config, lib, pkgs, ... }:

{
  imports = [
    # Default modules (core utilities)
    ./openssh.nix

    # Unused
    # ./unused/git.nix
    # ./unused/neovim-global.nix
    # ./unused/zsh-global.nix
  
    # Container runtimes
    ./docker.nix
    ./podman.nix
    
    # Virtualization
    ./libvirt.nix
    
    # Networking
    ./netbird.nix
    ./ncs-wireguard-access.nix
    
    # Development tools
    ./tmux.nix
    
    # Other utilities
    ./others/nixld.nix
    ./others/vscode-server.nix
    ./others/hd-idle.nix
    
    # Home manager configuration
    ./home-manager.nix
    
    # User modules (new system)
    ../users/samuel.nix
    ../users/nico.nix
    ../users/root.nix
    ../users/pibackups.nix
  ];

  # Enable default modules by default (can be overridden per-system)
  # These are fundamental tools that should be on most systems
  # myModules.git is now configured via home-manager
  # myModules.neovim.enable = lib.mkDefault true;
  myModules.openssh.enable = lib.mkDefault true;
  myModules.homeManager.enable = lib.mkDefault true;
  
  # Optional modules disabled by default (enable per-system as needed)
  # myModules.zshGlobal is disabled by default (ZSH configured via home-manager)
  # myModules.docker.enable = false; (default)
  # myModules.podman.enable = false; (default)
  # myModules.netbird.enable = false; (default)
  # myModules.ncsWireguard.enable = false; (default)
  # myModules.tmux.enable = false; (default)
  # myModules.nixld.enable = false; (default)
  # myModules.vscodeServer.enable = false; (default)
  # myModules.hdIdle.enable = false; (default)
}
