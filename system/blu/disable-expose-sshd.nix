{ config, lib, pkgs, ... }@inputs:

{
  services.openssh.openFirewall = false;
}
