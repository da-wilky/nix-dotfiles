{ config, lib, pkgs, ... }@inputs: 

{
  #
  #	CONFIG WAS NOT WORKING
  #	  AND IS CURRENTLY NOT IN USE
  #

  environment.systemPackages = with pkgs; [
    hd-idle
  ];

  systemd.services.hd-idle = {
    description = "External HDD spin down daemon";
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 0 -a sda -i 90";
      #Restart = "on-failure";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ];
  };
  systemd.services.hd-idle.enable = true;
}
