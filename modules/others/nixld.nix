{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.nixld = {
    enable = mkEnableOption "Nix-LD for running unpatched binaries";
    
    libraries = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional libraries to make available";
    };
  };

  config = mkIf config.myModules.nixld.enable {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = config.myModules.nixld.libraries;
  };
}
