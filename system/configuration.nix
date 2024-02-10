# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # enable Font folder
  fonts.fontDir.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.samuel = {
    isNormalUser = true;
    description = "Samuel";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDhEujw7+sYxnJsZ9KaPbaHrllnrVPmnfa2QBmTKD4fmYb9gT8El8WCL5C/UwVroDH5bGVbX14VWLhfAZI0A98Y2mivMrrtzn50X/63lKBOb+v5QWPy85xEjaPOrNwcF2Bdc5iSOMeL65M8tm7CDZrj+pNhI2xiVZIp2tAhQ3TIxuCc4P9eNXsNzLJRvqSppVSOgITYJ9AT0r55RldY/PCMGjmmmHoxE7bnSe3Ma+VnpN8F9pEQoy8RAMo9HRtJ4GbLHpqSgX8cT8SFk6l00UfGc41YhjDd962qIK81wC30AzoZwFDSz6/JTkgFSpNdGyHZjdV8qHE60J91hIoargmdJP/Lmx73tHct63UlhFGfIwACi5bzU4+AFm8L3MGJlu8VV7BOIu3IlNZUNLztijU+lzo2eAiXMlH8SPFKOWF74Dbk8nKAmhFGczXkvLs7JPT5oTiv++xUfTQfjDnZTGiGQKUSs5Co6Bg+l/jgF6NjJwVAyEXC+C2QYPbJ00y3Kb8=" ];
  };
  security.sudo.wheelNeedsPassword = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix Settings
  nix.settings.experimental-features = ["nix-command" "flakes"];

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  virtualisation.docker.enable = true;

  programs = {
    git = {
      enable = true;
      config = {
	init.defaultBranch = "main";
      };
    };
    zsh = {
      enable = true;
      autosuggestions = {
        enable = true;
	strategy = [ "completion" ];
	async = true;
      };
      syntaxHighlighting.enable = true;
      zsh-autoenv.enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      ohMyZsh = {
        enable = true;
	plugins = [ "git" "sudo" "docker" "history" "colorize" "direnv" ];
        theme = "alanpeabody";
      };
      shellAliases = {
        v = "nvim";
	vim = "nvim";
	nixupdate = "sudo nixos-rebuild switch --flake ~/dotfiles/";
        nixconfig = "nvim ~/dotfiles/system/configuration.nix";
	nixprograms = "nvim ~/dotfiles/system/program.nix";
	nixdir = "echo \"use flake\" > .envrc && direnv allow";
	vscodeserver = "code tunnel --accept-server-license-terms --name Homeserver";
      };
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      viAlias = true;
      withPython3 = true;
      configure = {
        customRC = ''
		  set number shiftwidth=2
		'';
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            colorizer
            fugitive
            nerdtree
            nvim-treesitter-refactor
            nvim-treesitter.withAllGrammars
            vim-tmux
            vim-tmux-navigator
	  ];
	};
      };
    };

    tmux = {
      enable = true;
      keyMode = "vi";
      terminal = "screen-256color\"\nset -g mouse on\n# \"";
      # shortcut = "Space";
      baseIndex = 1;
      clock24 = true;
      plugins = with pkgs.tmuxPlugins; [
	#  nord
	vim-tmux-navigator
	#  sensible
	#  yank
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
