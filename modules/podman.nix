{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.podman = {
    enable = mkEnableOption "Podman container runtime";
    
    dockerCompat = mkOption {
      type = types.bool;
      default = false;
      description = "Create docker alias for podman";
    };
    
    enableNvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA GPU support";
    };
  };

  config = mkIf config.myModules.podman.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = config.myModules.podman.dockerCompat;
      enableNvidia = config.myModules.podman.enableNvidia;
      defaultNetwork.settings.dns_enabled = true;
    };
    
    # Declare that this module provides the podman group
    myModules.providedGroups = [ "podman" ];
  };
}
