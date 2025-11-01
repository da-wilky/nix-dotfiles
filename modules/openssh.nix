{ config, lib, ... }:

with lib;

{
  options.myModules.openssh = {
    enable = mkEnableOption "OpenSSH server" // { default = true; };
    
    permitRootLogin = mkOption {
      type = types.enum [ "yes" "no" "prohibit-password" "forced-commands-only" ];
      default = "no";
      description = "Whether root can login via SSH";
    };
    
    passwordAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = "Allow password authentication (key-only is more secure)";
    };
    
    ports = mkOption {
      type = types.listOf types.port;
      default = [ 22 ];
      description = "SSH server ports";
    };
    
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically open firewall ports";
    };
  };

  config = mkIf config.myModules.openssh.enable {
    services.openssh = {
      enable = true;
      ports = config.myModules.openssh.ports;
      openFirewall = config.myModules.openssh.openFirewall;
      settings = {
        PermitRootLogin = config.myModules.openssh.permitRootLogin;
        PasswordAuthentication = config.myModules.openssh.passwordAuthentication;
      };
    };
  };
}
