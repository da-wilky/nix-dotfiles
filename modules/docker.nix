{ config, ... }@inputs: 

{
  virtualisation.docker = {
    enable = true;
    liveRestore = false;
  };
}
