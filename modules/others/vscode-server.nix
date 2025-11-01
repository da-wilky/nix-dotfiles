{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myModules.vscodeServer;
in
{
  imports = [ ./nixld.nix ];

  options.myModules.vscodeServer = {
    enable = mkEnableOption "VSCode Server Daemon";
    
    user = mkOption {
      type = types.str;
      default = "samuel";
      description = "User to run the VSCode server as";
    };
    
    tunnelName = mkOption {
      type = types.str;
      default = "Homeserver";
      description = "Name for the VSCode tunnel";
    };
    
    installVSCode = mkOption {
      type = types.bool;
      default = true;
      description = "Install VSCode package system-wide";
    };
  };

  config = mkIf cfg.enable {
    # Enable nixld for VSCode server
    myModules.nixld.enable = true;

    environment.systemPackages = mkIf cfg.installVSCode [ pkgs.vscode ];

    systemd.services.vscode-server-daemon = {
      description = "VSCode Server Daemon";
      serviceConfig = {
        ExecStart = "${pkgs.vscode}/bin/code tunnel --accept-server-license-terms --name ${cfg.tunnelName}";
        Restart = "on-failure";
        User = cfg.user;
        Environment = [
          ''"NIX_LD_LIBRARY_PATH=${lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]}"''
          ''"NIX_LD=${pkgs.glibc}/lib/ld-linux-x86-64.so.2"''
        ];
      };
      path = [ "/run/current-system/sw" ];
      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      enable = true;
    };
  };
}
