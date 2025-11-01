{ config, pkgs, name, homeDirectory, ... }:

{
  imports = [
    ../../modules/home/default.nix
  ];

  # Base configuration only
  myHomeModules.base = {
    enable = true;
    username = name;
    homeDirectory = homeDirectory;
    stateVersion = "24.05";
  };

  # Minimal modules for system user
  myHomeModules.git.enable = true;
  myHomeModules.zsh.enable = true;
  myHomeModules.neovim.enable = true;
  myHomeModules.ssh.enable = false;  # System user doesn't need SSH config
}
