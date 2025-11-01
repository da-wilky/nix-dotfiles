{ config, lib, pkgs, ... }:

with lib;

{
  #
  # CONFIG WAS NOT WORKING AND IS CURRENTLY NOT IN USE
  # Enable at your own risk - needs testing
  #

  options.myModules.hdIdle = {
    enable = mkEnableOption "HD-Idle - External HDD spin down daemon";
    
    installPackage = mkOption {
      type = types.bool;
      default = true;
      description = "Install hd-idle package system-wide";
    };
    
    idleTime = mkOption {
      type = types.int;
      default = 90;
      description = "Idle time in seconds before spinning down";
    };
    
    device = mkOption {
      type = types.str;
      default = "sda";
      description = "Device to monitor (e.g., sda, sdb)";
    };
    
    commandLineArgs = mkOption {
      type = types.str;
      default = "";
      description = "Additional command line arguments for hd-idle";
    };
  };

  config = mkIf config.myModules.hdIdle.enable {
    environment.systemPackages = mkIf config.myModules.hdIdle.installPackage [ pkgs.hd-idle ];

    systemd.services.hd-idle = {
      description = "External HDD spin down daemon";
      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 0 -a ${config.myModules.hdIdle.device} -i ${toString config.myModules.hdIdle.idleTime}${optionalString (config.myModules.hdIdle.commandLineArgs != "") " ${config.myModules.hdIdle.commandLineArgs}"}";
        User = "root";
      };
      wantedBy = [ "multi-user.target" ];
      enable = true;
    };
  };
}
