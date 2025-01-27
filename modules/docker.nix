{ config, ... }@inputs: 

{
  virtualisation.docker = {
    enable = true;
    liveRestore = false;
  };
  #virtualisation.docker.daemon.settings = {
  #  dns = [ "8.8.8.8" "8.8.4.4" ];
  #};
}
