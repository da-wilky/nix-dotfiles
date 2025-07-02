{config, pkgs, lib, ... }@inputs:

let
  params = {
    name = "pibackups";
    homeDirectory = "/home/pibackups";
    useZSH = true;
    useNVIM = true;
  };
  inherit (params) name useZSH homeDirectory;
in
{
  # Enable ZSH
  programs.zsh.enable = true;
  
  # Setup User
  users.users.${name} = {
    isSystemUser = true;
    group = "${name}";
    description = "Backup User the backup services connect with.";
    #createHome = true;
    #home = "${homeDirectory}";
    shell = if useZSH then pkgs.zsh else pkgs.bash;
    packages = with pkgs; [];
    openssh.authorizedKeys.keyFiles = [ ./keys/pibackups ];
  };
  users.groups.${name} = {};

  # Setup Home
  home-manager.users.${name} = ({ config, pkgs, ... }: import ./homes/default/home.nix ({ inherit config pkgs;} // params));
}
