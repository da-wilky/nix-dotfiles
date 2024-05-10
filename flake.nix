{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  #inputs.nixpkgs.url = github:NixOS/nixpkgs/master;

  inputs.vscode-server.url = github:nix-community/nixos-vscode-server;

  inputs.agenix.url = github:ryantm/agenix;

  outputs = { self, nixpkgs, vscode-server, agenix, ... }@attrs:
    let
      system = "x86_64-linux";
  
      # agenix
      agenixpkg = agenix.packages.${system}.default;
      agenixmodule = [ 
	agenix.nixosModules.default 
	{
	  environment.systemPackages = [ agenixpkg ];
	}
      ];
    in
    {
      nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
	inherit system;
	modules = [
	  ./system/homeserver/configuration.nix
	  vscode-server.nixosModules.default
	  ({ config, pkgs, ... }: {
	    services.vscode-server.enable = true;
	  })
	] ++ agenixmodule;
      };
      nixosConfigurations.blu = nixpkgs.lib.nixosSystem {
	inherit system;
	modules = [
	  ./system/blu/configuration.nix
	] ++ agenixmodule;
      };
    };
}
