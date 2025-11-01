{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myUsers.root;
  
  params = {
    name = "root";
    homeDirectory = "/root";
  };

  inherit (params) name;
in
{
  options.myUsers.root = {
    enableHomeManager = mkEnableOption "Home Manager for root" // { default = true; };
  };

  config = {
    # Enable ZSH (managed by home-manager module)
    programs.zsh.enable = true;

    # Set ZSH default shell for root
    users.users.${name}.shell = pkgs.zsh;

    # Setup Home for root
    home-manager.users.${name} = mkIf cfg.enableHomeManager (
      {config, pkgs, ...}: import ./homes/root.nix ( { inherit config pkgs; } // params )
    );
  };
}
