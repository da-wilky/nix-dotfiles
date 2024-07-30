{ config, lib, pkgs, ... }@inputs: 

{
  #programs.nix-ld.dev.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [];
}
