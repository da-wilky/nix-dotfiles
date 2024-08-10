{ config, lib, pkgs, ... }@inputs: 

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };
}
