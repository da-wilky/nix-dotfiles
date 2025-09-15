{ config, ... }@inputs: 

let
  sopsFile = ../ncsystems-secrets.yml;
in
{
  sops = {
    secrets = {
      nc-systems-wireguard-config = {
	inherit sopsFile;
      };
      nc-systems-wireguard-172-config = {
	inherit sopsFile;
      };
    };
  };

  networking = {
    wg-quick = {
      interfaces = {
	wgnc.configFile = config.sops.secrets.nc-systems-wireguard-config.path; 
	wgnci.configFile = config.sops.secrets.nc-systems-wireguard-172-config.path;
      };
    };
  };
}
