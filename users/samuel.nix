{ config, pkgs, lib, ... }@inputs:

let
  params = {
    name = "samuel";
    homeDirectory = "/home/samuel";
    useZSH = true;
    useNVIM = true;
  };

  inherit (params) name useZSH homeDirectory;
in
{
  # Enable ZSH
  programs.zsh.enable = true;

  # Create user
  users.users.${name} = {
    isNormalUser = true;
    description = "Samuel";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = if useZSH then pkgs.zsh else pkgs.bash;
    packages = with pkgs; [];
    openssh.authorizedKeys.keyFiles = [ ./keys/samuel ];
  };

  home-manager.users.${name} = ({config, pkgs, ... }: import ./homes/samuel.nix ( { inherit config pkgs; } // params ));

  sops = {
    defaultSopsFile = ./secrets/samuel.yml;
    secrets.samuel-ssh-key = {
      path = "${homeDirectory}/.ssh/id_ed25519";
      mode = "0400";
      owner = "${name}";
    };
    # This Step needs to be done here. Else the user has no age key to decrypt the secrets.
    secrets.samuel-age-key = {
      path = "${homeDirectory}/.config/sops/age/keys.txt";
      mode = "0400";
      owner = "${name}";
    };
  };
}
