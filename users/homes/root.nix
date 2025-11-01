{ config, pkgs, name, homeDirectory, ... }:

{
  imports = [
    ../../modules/home/default.nix
  ];

  # Base configuration
  myHomeModules.base = {
    enable = true;
    username = name;
    homeDirectory = homeDirectory;
    stateVersion = "24.05";
  };

  # Enable modules for root user
  myHomeModules.git.enable = true;
  myHomeModules.zsh.enable = true;
  myHomeModules.neovim.enable = true;
  myHomeModules.ssh.enable = false;  # Root typically doesn't need SSH client config
}
