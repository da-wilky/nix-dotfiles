{ config, pkgs, name, homeDirectory, useZSH ? true, useNVIM ? true, ... }@i:

{

  imports = [
    (import ./default/home.nix i)
  ];

  # This could be done here, but keep it on system level
  #sops = {
  #  age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
  #  defaultSopsFile = ../secrets/samuel.yml;
  #  secrets.samuel-ssh-key = {
  #    path = "${homeDirectory}/.ssh/id_ed25519";
  #    mode = "0400";
  #  };
  #};

  home.file.".ssh/id_ed25519.pub".text = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAWEue89TqiVnWtTnBka40kV9md2ImfV2cpVgR/kgUS samuel@nixos'';
}

