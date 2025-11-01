{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./git.nix
    ./zsh.nix
    ./neovim.nix
    ./ssh.nix
  ];
}
