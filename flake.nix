{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  #inputs.nixpkgs.url = github:NixOS/nixpkgs/master;

  inputs.vscode-server.url = github:nix-community/nixos-vscode-server;

  inputs.agenix.url = github:ryantm/agenix;

  outputs = { self, nixpkgs, vscode-server, agenix, ... }@attrs:
    let
      system = "x86_64-linux";
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
	];
      };
      nixosConfigurations.blu = nixpkgs.lib.nixosSystem {
	inherit system;
	modules = [
	  ./system/blu/configuration.nix
	  agenix.nixosModules.default
	  {
	    environment.systemPackages = [ agenix.packages.${system}.default ];
	  }
	];
      };
    };
}
