{config, pkgs, lib, ... }@inputs:

{
  users.users.pibackups = {
    isSystemUser = true;
    group = "pibackups";
    description = "Backup User the backup services connect with.";
    createHome = true;
    home = "/home/pibackups";
    shell = lib.mkDefault pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keyFiles = [ ./keys/pibackups ];
  };
  users.groups.pibackups = {};
}
