{ config, lib, pkgs, inputs, ... }:

with lib;

{
  options.myModules.netbird = {
    enable = mkEnableOption "Netbird VPN client";
    
    useUnstable = mkOption {
      type = types.bool;
      default = true;
      description = "Use unstable package from nixpkgs-unstable";
    };
    
    clients = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          port = mkOption {
            type = types.port;
            default = 51820;
            description = "Port for this netbird client";
          };
          
          name = mkOption {
            type = types.str;
            default = "netbird";
            description = "Name of the netbird client";
          };
          
          interface = mkOption {
            type = types.str;
            description = "Network interface name";
          };
          
          hardened = mkOption {
            type = types.bool;
            default = false;
            description = "Enable hardened mode";
          };
          
          dns-resolver = mkOption {
            type = types.submodule {
              options = {
                address = mkOption {
                  type = types.str;
                  default = "127.0.0.153";
                  description = "DNS resolver address";
                };
                
                port = mkOption {
                  type = types.port;
                  default = 53;
                  description = "DNS resolver port";
                };
              };
            };
            default = {
              address = "127.0.0.153";
              port = 53;
            };
            description = "DNS resolver configuration";
          };
        };
      });
      default = {
        "wt0" = {
          port = 51820;
          name = "netbird";
          interface = "wt0";
          hardened = false;
          dns-resolver = {
            address = "127.0.0.153";
            port = 53;
          };
        };
      };
      description = "Netbird client configurations";
    };
  };

  config = mkIf config.myModules.netbird.enable {
    services.netbird.package = if config.myModules.netbird.useUnstable 
      then inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.netbird
      else pkgs.netbird;
    
    services.netbird.clients = config.myModules.netbird.clients;
  };
}
