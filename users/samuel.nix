{ config, pkgs, lib, ... }@inputs:

{
  programs.zsh.enable = true;
  
  users.users.samuel = {
    isNormalUser = true;
    description = "Samuel";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = lib.mkDefault pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keyFiles = [ ./keys/samuel ];
  };

  sops = {
    defaultSopsFile = ./samuel.yml;
    secrets.samuel-ssh-key = {
      path = "${toString config.users.users.samuel.home}/.ssh/id_ed25519";
      mode = "0400";
      owner = config.users.users.samuel.name;
    };
    secrets.samuel-age-key = {
      path = "${toString config.users.users.samuel.home}/.config/sops/age/keys.txt";
      mode = "0400";
      owner = config.users.users.samuel.name;
    };
  };
}
