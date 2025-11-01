{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.homeManager = {
    enable = mkEnableOption "Home Manager integration" // { default = true; };
    
    useGlobalPkgs = mkOption {
      type = types.bool;
      default = true;
      description = "Use system-wide package collection in home-manager";
    };
    
    useUserPackages = mkOption {
      type = types.bool;
      default = true;
      description = "Install user packages through system profile";
    };
    
    backupFileExtension = mkOption {
      type = types.str;
      default = "backup";
      description = "Extension for backup files when home-manager overwrites existing files";
    };
  };

  config = mkIf config.myModules.homeManager.enable {
    home-manager = {
      useGlobalPkgs = config.myModules.homeManager.useGlobalPkgs;
      useUserPackages = config.myModules.homeManager.useUserPackages;
      backupFileExtension = config.myModules.homeManager.backupFileExtension;
    };
  };
}
