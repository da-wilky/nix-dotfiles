{ config, pkgs, name, homeDirectory, userConfig ? {}, gitNameFile ? null, gitEmailFile ? null, ... }:

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
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAWEue89TqiVnWtTnBka40kV9md2ImfV2cpVgR/kgUS samuel@nixos";
  };

  # Enable modules based on user preferences
  myHomeModules.git = {
    enable = userConfig.git.enable or true;
    userNameFile = gitNameFile;
    userEmailFile = gitEmailFile;
  };
  myHomeModules.zsh.enable = userConfig.zsh.enable or true;
  myHomeModules.neovim.enable = userConfig.neovim.enable or true;
  myHomeModules.ssh = {
    enable = userConfig.ssh.enable or false;
    activateGithub = userConfig.ssh.activateGithub or true;
    activatePibackups = userConfig.ssh.activatePibackups or false;
  };
}
