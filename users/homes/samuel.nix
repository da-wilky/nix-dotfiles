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

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
	identitiesOnly = true;
      };
      "github.com" = {
	hostname = "github.com";
	user = "git";
	port = 22;
	identityFile = "~/.ssh/github";
      };
    };
  };

  #programs.git = {
  #  enable = true;
  #  userEmail = "samuel.wilk.00@gmail.com";
  #  userName = "Samuel Wilk";
  #  extraConfig = {};
  #  signing = {
  #    key = ;
  #    signByDefault = true;
  #  };
  #};

  home.file.".ssh/id_ed25519.pub".text = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAWEue89TqiVnWtTnBka40kV9md2ImfV2cpVgR/kgUS samuel@nixos'';
}

