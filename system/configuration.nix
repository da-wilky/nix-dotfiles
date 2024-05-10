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
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHpC8wD8E/BsQ7dLAjatwIzhvL0cR20rwtFauf0Oa1p" ];
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
	alias = {
	  ci = "commit";
	  co = "checkout";
	  st = "status";
	  undo = "reset --soft HEAD^";

	  localignore = "update-index --skip-worktree";
	  localunignore = "update-index --no-skip-worktree";
	};
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
	#nixupdate = "sudo nixos-rebuild switch --flake ~/dotfiles/";
        nixconfig = "nvim ~/dotfiles/system/configuration.nix";
	nixprograms = "nvim ~/dotfiles/system/program.nix";
	nixflake = "nvim ~/dotfiles/flake.nix";
	nixdir = "echo \"use flake\" > .envrc && direnv allow";
	#vscodeserver = "code tunnel --accept-server-license-terms --name Homeserver";
	#builddocker = "nix build && docker load < result && rm result";
	builddocker = "nix build --no-link --print-out-paths | { read imagePath; docker load < \"$imagePath\"; }";
	#builddockerversion = "nix build .#version && docker load < result && rm result";
	builddockerversion = "nix build .#version --no-link --print-out-paths | { read imagePath; docker load < \"$imagePath\"; }";
	dockerrestart = "docker compose down && docker compose up -d";
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
