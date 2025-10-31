{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-25.05;
    #inputs.nixpkgs.url = github:NixOS/nixpkgs/master;

    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixos-unstable;

    vscode-server = {
      url = github:nix-community/nixos-vscode-server;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = github:ryantm/agenix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = github:Mic92/sops-nix;
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = github:nixos/nixos-hardware;

    # Raspberry Pi 5
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
  };

  # Cache Server for Raspberry Pi 5
  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, vscode-server, agenix, sops-nix, nixos-hardware, home-manager, nixos-raspberrypi, ... }@inputs:
    let
      system = "x86_64-linux";
      pi_system = "aarch64-linux";  

      # agenix
      #agenixmodule = i@{ system ? "x86_64-linux", ... }:
      #	[ 
      #	agenix.nixosModules.default 
      #	{
      #	  environment.systemPackages = [ agenix.packages.${i.system}.default ];
      #	}
      #];
    in
    {
      nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
	inherit system;
	specialArgs = { inherit inputs; };
	modules = [
	  ./system/homeserver/configuration.nix
	  
	  ./users/defaultUsers.nix
	  ./users/nico.nix

	  ./modules/default.nix
	  ./modules/docker.nix
	  ./modules/netbird.nix
	  ./modules/others/nixld.nix
	  #./modules/others/vscode-server.nix

	  ./modules/ncs-wireguard-access.nix

	  sops-nix.nixosModules.sops
	  #vscode-server.nixosModules.default
	  #({ config, pkgs, ... }: {
	  #  services.vscode-server.enable = true;
	  #  services.vscode-server.enableFHS = true;
	  #})

	  home-manager.nixosModules.home-manager
	  ./modules/home-manager.nix
	];
	# ++ agenixmodule { inherit system; };
      };
      nixosConfigurations.blu = nixpkgs.lib.nixosSystem {
	inherit system;
	specialArgs = { inherit inputs; };
	modules = [
	  ./system/blu/configuration.nix

	  ./users/defaultUsers.nix

	  ./modules/default.nix
	  ./modules/docker.nix
	  ./modules/netbird.nix
	  ./modules/others/nixld.nix

	  sops-nix.nixosModules.sops

	  home-manager.nixosModules.home-manager
	  #	Need this to use sops inside home-manager
	  #{
	  #  home-manager.sharedModules = [
	  #    sops-nix.homeManagerModules.sops
	  #  ];
	  #}
	  ./modules/home-manager.nix
	];
	# ++ agenixmodule { inherit system; };
      };
      nixosConfigurations.pangolier = nixpkgs.lib.nixosSystem {
	inherit system;
	specialArgs = { inherit inputs; };
	modules = [
	  ./system/pangolier/configuration.nix

	  ./users/defaultUsers.nix

	  ./modules/default.nix
	  ./modules/docker.nix
	  ./modules/netbird.nix
	  ./modules/others/nixld.nix

	  sops-nix.nixosModules.sops

	  home-manager.nixosModules.home-manager
	  ./modules/home-manager.nix
	];
      };
      nixosConfigurations.pibackups = nixpkgs.lib.nixosSystem {
        system = pi_system;
	specialArgs = { inherit inputs; };
        modules = [
	  ./system/pibackups/configuration.nix
          
	  ./users/defaultUsers.nix
	  ./users/pibackups.nix
	  ./modules/default.nix
	  ./modules/docker.nix
	  ./modules/netbird.nix
	  #./modules/others/hd-idle.nix

	  nixos-hardware.nixosModules.raspberry-pi-4
	  sops-nix.nixosModules.sops
	
	  home-manager.nixosModules.home-manager
	  ./modules/home-manager.nix
	];
	# ++ agenixmodule { system = pi_system; };
      };
      nixosConfigurations.pi5dd = nixos-raspberrypi.lib.nixosSystem {
        system = pi_system;
	specialArgs = { inherit inputs; nixos-raspberrypi = inputs.nixos-raspberrypi; };
        modules = [
	  # Raspberry Pi 5
          ({...}: {
	    imports = with nixos-raspberrypi.nixosModules; [
              raspberry-pi-5.base
            ];
          })

	  ./system/pi5dd/configuration.nix

          ./users/defaultUsers.nix
	  ./users/pibackups.nix
	  ./modules/default.nix
	  ./modules/netbird.nix
	  ./modules/docker.nix

	  sops-nix.nixosModules.sops

          home-manager.nixosModules.home-manager
          ./modules/home-manager.nix
        ];
      };
    };
}
