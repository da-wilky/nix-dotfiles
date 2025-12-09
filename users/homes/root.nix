{ config, pkgs, name, homeDirectory, homeConfig ? {}, ... }:

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
  myHomeModules.git.enable = homeConfig.git.enable or true;
  myHomeModules.zsh.enable = homeConfig.zsh.enable or true;
  myHomeModules.neovim.enable = homeConfig.neovim.enable or true;
  myHomeModules.ssh = {
    enable = homeConfig.ssh.enable or true;  # Root typically doesn't need SSH client config
    activateGithub = homeConfig.ssh.activateGithub or false;
    activatePibackups = homeConfig.ssh.activatePibackups or true;
  };
}