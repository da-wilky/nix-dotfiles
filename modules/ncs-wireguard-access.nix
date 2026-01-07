{ config, lib, ... }:

with lib;

let
  cfg = config.myModules.ncsWireguard;
  sopsFile = ../secrets/func/ncsystems.yml;
in
{
  options.myModules.ncsWireguard = {
    enable = mkEnableOption "NC Systems Wireguard Access";
    
    enableMainInterface = mkOption {
      type = types.bool;
      default = true;
      description = "Enable main wireguard interface (ncswg-nc-netz)";
    };
    
    enableHMTInterface = mkOption {
      type = types.bool;
      default = true;
      description = "Enable HMT wireguard interface (ncswg-hmt)";
    };
  };

  config = mkIf cfg.enable {
    sops = {
      secrets = mkMerge [
        (mkIf cfg.enableMainInterface {
          ncswg-nc-netz = {
            inherit sopsFile;
          };
        })
        (mkIf cfg.enableHMTInterface {
          ncswg-hmt = {
            inherit sopsFile;
          };
        })
      ];
    };

    networking = {
      wg-quick = {
        interfaces = mkMerge [
          (mkIf cfg.enableMainInterface {
            ncswg-nc-netz.configFile = config.sops.secrets.ncswg-nc-netz.path;
          })
          (mkIf cfg.enableHMTInterface {
            ncswg-hmt.configFile = config.sops.secrets.ncswg-hmt.path;
          })
        ];
      };
    };
  };
}
