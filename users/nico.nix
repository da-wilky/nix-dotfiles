{ config, pkgs, ... }@inputs:

{
  users.users.nico = {
    isNormalUser = true;
    description = "Nico";
    extraGroups = [ "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keyFiles = [ ./keys/nico ];
  };
}
