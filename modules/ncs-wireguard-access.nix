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
      description = "Enable main wireguard interface (wgnc)";
    };
    
    enable172Interface = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 172 wireguard interface (wgnci)";
    };
  };

  config = mkIf cfg.enable {
    sops = {
      secrets = mkMerge [
        (mkIf cfg.enableMainInterface {
          nc-systems-wireguard-config = {
            inherit sopsFile;
          };
        })
        (mkIf cfg.enable172Interface {
          nc-systems-wireguard-172-config = {
            inherit sopsFile;
          };
        })
      ];
    };

    networking = {
      wg-quick = {
        interfaces = mkMerge [
          (mkIf cfg.enableMainInterface {
            wgnc.configFile = config.sops.secrets.nc-systems-wireguard-config.path;
          })
          (mkIf cfg.enable172Interface {
            wgnci.configFile = config.sops.secrets.nc-systems-wireguard-172-config.path;
          })
        ];
      };
    };
  };
}
