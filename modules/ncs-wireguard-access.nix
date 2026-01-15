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
      default = false;
      description = "Enable main wireguard interface (ncswg-nc-netz)";
    };
    
    enableHMTInterface = mkOption {
      type = types.bool;
      default = false;
      description = "Enable HMT wireguard interface (ncswg-hmt)";
    };

    enableNCTestInterface = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NC Test wireguard interface (ncswg-nc-test)";
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
        (mkIf cfg.enableNCTestInterface {
          ncswg-nc-testnetz = {
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
          (mkIf cfg.enableNCTestInterface {
            ncswg-nc-testnetz.configFile = config.sops.secrets.ncswg-nc-testnetz.path;
          })
        ];
      };
    };
  };
}
