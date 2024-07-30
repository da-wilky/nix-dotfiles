{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-24.05;
  #inputs.nixpkgs.url = github:NixOS/nixpkgs/master;

  inputs.vscode-server.url = github:nix-community/nixos-vscode-server;
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = github:ryantm/agenix;
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.sops-nix.url = github:Mic92/sops-nix;
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
  
  inputs.nixos-hardware.url = github:nixos/nixos-hardware;

  outputs = { self, nixpkgs, vscode-server, agenix, sops-nix, nixos-hardware, ... }@inputs:
    let
      system = "x86_64-linux";
      pi_system = "aarch64-linux";  

      # agenix
      agenixmodule = i@{ system ? "x86_64-linux", ... }:
	[ 
	agenix.nixosModules.default 
	{
	  environment.systemPackages = [ agenix.packages.${i.system}.default ];
	}
      ];
    in
    {
      nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
	inherit system;
	modules = [
	  ./system/homeserver/configuration.nix
	  sops-nix.nixosModules.sops
	  vscode-server.nixosModules.default
	  ({ config, pkgs, ... }: {
	    services.vscode-server.enable = true;
	  })
	] ++ agenixmodule { inherit system; };
      };
      nixosConfigurations.blu = nixpkgs.lib.nixosSystem {
	inherit system;
	modules = [
	  ./system/blu/configuration.nix
	  sops-nix.nixosModules.sops
	] ++ agenixmodule { inherit system; };
      };
      nixosConfigurations.pibackups = nixpkgs.lib.nixosSystem {
        system = pi_system;
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./system/pibackups/configuration.nix
	  sops-nix.nixosModules.sops
        ] ++ agenixmodule { system = pi_system; };
      };
    };
}
