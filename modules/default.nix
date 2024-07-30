{ config, lib, pkgs, ... }@inputs: 

{
  imports = [
    ./default/git.nix
    ./default/neovim.nix
    ./default/openssh.nix
    ./default/zsh.nix
  ];
}
