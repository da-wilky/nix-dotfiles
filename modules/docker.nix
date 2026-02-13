{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.docker = {
    enable = mkEnableOption "Docker virtualization";
    
    liveRestore = mkOption {
      type = types.bool;
      default = false;
      description = "Enable docker live restore";
    };
    
    enableOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Start docker on boot";
    };
    
    ipv6 = mkOption {
      type = types.bool;
      default = false;
      description = "Enable IPv6 for docker networks";
    };
    
    fixedCidrV6 = mkOption {
      type = types.str;
      default = "fd00::/80";
      description = "IPv6 CIDR for docker";
    };
    
    trustDockerInterfaces = mkOption {
      type = types.bool;
      default = true;
      description = "Trust docker network interfaces in firewall (br-+, veth+, docker0, docker_gwbridge)";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra packages to install for docker";
    };
  };

  config = mkIf config.myModules.docker.enable {
    virtualisation.docker = {
      enable = true;
      liveRestore = config.myModules.docker.liveRestore;
      enableOnBoot = config.myModules.docker.enableOnBoot;
      extraPackages = config.myModules.docker.extraPackages;
      daemon.settings = mkIf config.myModules.docker.ipv6 {
        ipv6 = true;
        fixed-cidr-v6 = config.myModules.docker.fixedCidrV6;
      };
    };
    
    # Trust docker network interfaces in firewall
    networking.firewall.trustedInterfaces = mkIf config.myModules.docker.trustDockerInterfaces [
      "br-+"
      "veth+"
      "docker0"
      "docker_gwbridge"
    ];
    
    # Declare that this module provides the docker group
    myModules.providedGroups = [ "docker" ];
  };
}
