{ pkgs, lib, ... }@inputs:

let
  name = "pibackups";
  homeDirectory = "/home/pibackups";
  useZSH = true;
  useNVIM = true;
in
{
  users.users.${name}.shell = if useZSH then pkgs.zsh else pkgs.bash;

  home-manager.users.${name} = import ./default/home.nix { 
    inherit name homeDirectory useZSH useNVIM;
  };
}
