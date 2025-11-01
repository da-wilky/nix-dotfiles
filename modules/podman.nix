{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myModules.podman;
in
{
  options.myModules.podman = {
    enable = mkEnableOption "Podman container runtime";
    
    dockerCompat = mkOption {
      type = types.bool;
      default = false;
      description = "Create docker alias for podman";
    };

    compose = {
      enable = mkOption {
	type = types.bool;
	default = true;
	description = "Install podman-compose";
      };

      backend = mkOption {
	type = types.enum [ "all" "podman" "docker" ];
	default = "podman";
	description = "Which compose backend to use";
      };
    };

    dockerSocket = {
      enable = mkOption {
	type = types.bool;
	default = false;
	description = "Activate the podman.socket";
      };
    };

    enableNvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA GPU support";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = cfg.dockerCompat;
      enableNvidia = cfg.enableNvidia;
      dockerSocket.enable = cfg.dockerSocket.enable;
      defaultNetwork.settings.dns_enabled = true;
    };

    environment.systemPackages = mkIf cfg.compose.enable (let
      composePackages = 
	if cfg.compose.backend == "all" then [ pkgs.podman-compose pkgs.docker-compose ]
	else if cfg.compose.backend == "podman" then [ pkgs.podman-compose ]
	else if cfg.compose.backend == "docker" then [ pkgs.docker-compose ]
	else [];
    in composePackages);
    
    # Declare that this module provides the podman group
    myModules.providedGroups = [ "podman" ];
  };
}
