{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    #inputs.nixpkgs.url = github:NixOS/nixpkgs/master;

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    db_backup_scripts = {
      url = "git+https://github.com/da-wilky/db_backup_scripts.git";
      flake = false;
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      # inputs.nixpkgs.follows = "nixpkgs"; # is non existent
    };

    # nixpkgs25_05.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Raspberry Pi 5
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      #inputs.nixpkgs.follows = "nixpkgs25_05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Cache Server for Raspberry Pi 5
  nixConfig = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, vscode-server, agenix, sops-nix
    , nixos-hardware, home-manager, nixos-raspberrypi, db_backup_scripts, ... }@inputs:
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
    in {
      nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
	inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./system/homeserver/configuration.nix

          # All core modules and users (loaded via default.nix, enable as needed)
          ./modules/default.nix

          # System-specific configuration
          {
            myModules.docker.enable = true;
            myModules.netbird.enable = true;
            myModules.nixld.enable = true;
            myModules.ncsWireguard.enable = true;

            myUsers.samuel.homeModules.ssh.extraMatchBlocks = {
              "gitlab.rn.inf.tu-dresden.de" = {
                hostname = "gitlab.rn.inf.tu-dresden.de";
                user = "git";
                port = 22;
                identityFile = "~/.ssh/tu";
              };
            };
            
            # Libvirt/KVM virtualization
            myModules.libvirt = {
              enable = true;
              users = [ "samuel" ];
              bridge = {
                enable = true;
                interface = "vmbr0";
                physicalInterface = "enp2s0";
              };
              vms = {
                ubuntu-vm = {
                  name = "ubuntu-vm";
                  memory = 4096;
                  cpus = 4;
                  diskSize = "100G";
                  diskPath = "/data/vm/disk/ubuntu-vm.qcow2";
                  imagePath = "/data/vm/iso/ubuntu-24.04.3-live-server-amd64.iso";
                  imageFormat = "iso";
                  autostart = false;
                  bridgeInterface = "vmbr0";
                };
              };
            };
          }

          # External modules
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };
      nixosConfigurations.blu = nixpkgs.lib.nixosSystem {
	inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./system/blu/configuration.nix

          # All core modules and users (loaded via default.nix, enable as needed)
          ./modules/default.nix

          # System-specific configuration
          {
            myModules.docker.enable = true;
            myModules.netbird.enable = true;
            myModules.nixld.enable = true;

	    myModules.openssh.openFirewall = false;
          }

          # External modules
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };
      nixosConfigurations.lunar = nixpkgs.lib.nixosSystem {
	inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./system/lunar/configuration.nix

          # All core modules and users (loaded via default.nix, enable as needed)
          ./modules/default.nix

          # System-specific configuration
          {
            myModules.docker.enable = true;
	    myModules.netbird.enable = true;

	    myModules.openssh.openFirewall = false;
          }

          # External modules
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };
      nixosConfigurations.pangolier = nixpkgs.lib.nixosSystem {
	inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./system/pangolier/configuration.nix

          # All core modules and users (loaded via default.nix, enable as needed)
          ./modules/default.nix

          # System-specific configuration
          {
            myModules.docker.enable = true;
	    #myModules.podman.enable = true;
	    #myModules.podman.dockerSocket.enable = true;
	    myModules.netbird.enable = true;

	    myModules.openssh.openFirewall = false;
          }

          # External modules
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };
      nixosConfigurations.pibackups = nixpkgs.lib.nixosSystem {
	system = pi_system;
        specialArgs = { inherit inputs; };
        modules = [
          ./system/pibackups/configuration.nix

          # All core modules and users (loaded via default.nix, enable as needed)
          ./modules/default.nix

          # System-specific configuration
          {
            myModules.docker.enable = true;
            myModules.netbird.enable = true;

            myUsers.pibackups.enable = true;
          }

          # External modules
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };
      nixosConfigurations.pi5dd = nixos-raspberrypi.lib.nixosSystem {
	system = pi_system;
        specialArgs = {
          inherit inputs;
          nixos-raspberrypi = inputs.nixos-raspberrypi;
        };
        modules = [
          # Raspberry Pi 5
          ({ ... }: {
            imports = with nixos-raspberrypi.nixosModules;
              [ raspberry-pi-5.base ];
	    boot.loader.raspberryPi.bootloader = "kernel";
          })
	  #{
	  #  boot.loader.raspberryPi = {
	  #    enable = true;
	  #    bootPath = "/boot";
	  #    bootloader = "kernel";
	  #  };
	  #}

          ./system/pi5dd/configuration.nix

          # All core modules and users (loaded via default.nix, enable as needed)
          ./modules/default.nix

          # System-specific configuration
          {
            myModules.docker.enable = true;
            myModules.netbird.enable = true;

            myUsers.pibackups.enable = true;
          }

          # External modules
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ];
      };
    };
}
