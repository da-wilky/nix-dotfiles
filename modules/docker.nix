{ config, ... }@inputs: 

{
  virtualisation.docker = {
    enable = true;
    liveRestore = false;
    enableOnBoot = true;
    daemon.settings = {
    # Enable IPv6 for docker networks
    #  ipv6 = true;
    #  fixed-cidr-v6 = "fd00::/80";
    };
  };
}
