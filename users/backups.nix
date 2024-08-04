{ config, pkgs, ... }@inputs:

{
  users.users.backups = {
    isSystemUser = true;
    description = "Backup User the backup services connect with.";
    createHome = true;
    home = "/data/backups";
    shell = pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keyFiles = [ ./keys/backups ];
  };
}
