{ config, lib, pkgs, ... }@inputs: 

{
  imports = [ ./nixld.nix ];

  #environment.variables = pkgs.lib.mkForce {
  #     "NIX_LD_LIBRARY_PATH" = lib.makeLibraryPath [
  #       pkgs.stdenv.cc.cc
  #       pkgs.openssl
  #        ];
  #      "NIX_LD" = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
  #};

  environment.systemPackages = with pkgs; [
    vscode
  ];

  systemd.services.vscode-server-daemon = {
    description = "VSCode Server Daemon";
    serviceConfig = {
      ExecStart = "${pkgs.vscode}/bin/code tunnel --accept-server-license-terms --name Homeserver";
      #ExecStop = "pkill code";
      Restart = "on-failure";
      User = "samuel";
      Environment = [''"NIX_LD_LIBRARY_PATH=${lib.makeLibraryPath [
	pkgs.stdenv.cc.cc
      ]}"'' ''"NIX_LD=${pkgs.glibc}/lib/ld-linux-x86-64.so.2"''];
    };
    path = [ "/run/current-system/sw" ];
    wantedBy = [ "default.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
  systemd.services.vscode-server-daemon.enable = true;
}
