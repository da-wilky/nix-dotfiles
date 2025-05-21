{ config, ... }@inputs: 

{
  sops.secrets.nc-systems-wireguard-config = {
    sopsFile = ../ncsystems-secrets.yml;
  };

  networking = {
    wg-quick = {
      interfaces = {
	wgnc.configFile = config.sops.secrets.nc-systems-wireguard-config.path; 
      };
    };
  };
}
