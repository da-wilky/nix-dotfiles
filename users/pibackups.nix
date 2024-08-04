{ config, pkgs, ... }@inputs:

{
  users.users.pibackups = {
    isSystemUser = true;
    group = "pibackups";
    description = "Backup User the backup services connect with.";
    createHome = true;
    home = "/data/backups";
    shell = pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keyFiles = [ ./keys/pibackups ];
  };
  users.groups.pibackups = {};
}
