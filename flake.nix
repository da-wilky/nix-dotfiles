{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  #inputs.nixpkgs.url = github:NixOS/nixpkgs/master;

  inputs.vscode-server.url = github:nix-community/nixos-vscode-server;

  outputs = { self, nixpkgs, vscode-server, ... }@attrs: {
    nixosConfigurations.homeserver = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
	./system/homeserver/configuration.nix
	vscode-server.nixosModules.default
        ({ config, pkgs, ... }: {
          services.vscode-server.enable = true;
        })
      ];
    };
  };
}
