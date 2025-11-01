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
    enable = userConfig.enableGit or true;
    userNameFile = gitNameFile;
    userEmailFile = gitEmailFile;
  };
  myHomeModules.zsh.enable = userConfig.enableZsh or true;
  myHomeModules.neovim.enable = userConfig.enableNeovim or true;
  myHomeModules.ssh.enable = userConfig.enableSsh or false;
}
