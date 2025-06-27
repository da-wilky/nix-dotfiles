{ config, lib, pkgs, inputs, ... }: 

{
  #services.netbird.enable = true;
  services.netbird.package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.netbird;
  services.netbird.clients = {
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
}
