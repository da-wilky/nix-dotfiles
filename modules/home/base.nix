{ config, lib, pkgs, ... }:

with lib;

{
  options.myHomeModules.base = {
    enable = mkEnableOption "Base home-manager configuration" // { default = true; };
    
    username = mkOption {
      type = types.str;
      description = "Username for home-manager";
    };
    
    homeDirectory = mkOption {
      type = types.str;
      description = "Home directory path";
    };
    
    stateVersion = mkOption {
      type = types.str;
      default = "24.05";
      description = "Home Manager state version";
    };
    
    sshPublicKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "SSH public key to install";
    };
  };

  config = mkIf config.myHomeModules.base.enable {
    programs.home-manager.enable = true;

    home.username = config.myHomeModules.base.username;
    home.homeDirectory = config.myHomeModules.base.homeDirectory;
    home.stateVersion = config.myHomeModules.base.stateVersion;
    
    home.file.".ssh/id_ed25519.pub" = mkIf (config.myHomeModules.base.sshPublicKey != null) {
      text = config.myHomeModules.base.sshPublicKey;
    };
  };
}
