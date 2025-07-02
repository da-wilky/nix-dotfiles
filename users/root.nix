{ config, pkgs, lib, ... }@inputs:

let
  params = {
    name = "root";
    homeDirectory = "/root";
    useZSH = true;
    useNVIM = true;
  };

  inherit (params) name useZSH;
in
{
  # Enable ZSH
  programs.zsh.enable = true;

  # Set ZSH default shell for root
  users.users.${name}.shell = if useZSH then pkgs.zsh else pkgs.bash;

  # Setup Home for root
  home-manager.users.${name} = ({config, pkgs, ...}: import ./homes/default/home.nix ( { inherit config pkgs; } // params ));
}
