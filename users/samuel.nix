{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myUsers.samuel;

  # Base groups that samuel should always have
  baseGroups = [ "networkmanager" "wheel" ];

  # Automatically collect groups from enabled modules
  moduleGroups = config.myModules.providedGroups or [ ];

  # Combine base groups with module-provided groups, plus any extra groups
  allGroups = baseGroups ++ moduleGroups ++ cfg.extraGroups;

  params = {
    name = "samuel";
    homeDirectory = "/home/samuel";
  };

  inherit (params) name homeDirectory;
in {
  options.myUsers.samuel = {
    enable = mkEnableOption "Samuel user account" // { default = true; };

    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional groups beyond base and module-provided groups";
      example = [ "audio" "video" ];
    };

    enableHomeManager = mkOption {
      type = types.bool;
      default = true;
      description = "Enable home-manager configuration";
    };

    enableSopsSecrets = mkOption {
      type = types.bool;
      default = true;
      description = "Enable sops secrets for this user";
    };

    loadSshKey = mkOption {
      type = types.bool;
      default = true;
      description = "Load SSH private key from sops secrets";
    };

    # Home module options
    homeModules = {
      git = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Git home-manager module";
        };
      };

      zsh = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable ZSH home-manager module";
        };
      };

      neovim = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Neovim home-manager module";
        };
      };

      ssh = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable SSH home-manager module";
        };

        activateGithub = mkOption {
          type = types.bool;
          default = true;
          description = "Activate SSH key for GitHub";
        };

        activatePibackups = mkOption {
          type = types.bool;
          default = false;
          description = "Activate SSH key for PiBackups";
        };

        extraMatchBlocks = mkOption {
          type = types.attrsOf (types.attrsOf types.anything);
          default = { };
          description = "Additional SSH match blocks for home-manager SSH module";
          example = {
            "example.com" = {
              hostname = "example.com";
              user = "myuser";
              port = 2222;
            };
          };
        };
      };
    };
  };

  # Global option for modules to declare what groups they provide
  options.myModules.providedGroups = mkOption {
    type = types.listOf types.str;
    default = [ ];
    internal = true;
    description =
      "Groups provided by enabled modules (automatically collected)";
  };

  config = mkIf cfg.enable {
    # Enable ZSH if the home module enables it
    programs.zsh.enable = cfg.homeModules.zsh.enable;

    # Create user with automatically collected groups
    users.users.${name} = {
      isNormalUser = true;
      description = "Samuel";
      extraGroups = allGroups;
      shell = if cfg.homeModules.zsh.enable then pkgs.zsh else pkgs.bash;
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keyFiles = [ ./keys/samuel ];
    };

    # Home Manager configuration
    home-manager.users.${name} = mkIf cfg.enableHomeManager (let
      gitNamePath = if cfg.homeModules.git.enable then
        config.sops.secrets.samuel-git-name.path
      else
        null;
      gitEmailPath = if cfg.homeModules.git.enable then
        config.sops.secrets.samuel-git-email.path
      else
        null;
    in { config, pkgs, ... }:
    import ./homes/samuel.nix ({
      inherit config pkgs;
      userConfig = cfg.homeModules;
      gitNameFile = gitNamePath;
      gitEmailFile = gitEmailPath;
    } // params));

    # Sops secrets
    sops = mkIf cfg.enableSopsSecrets {
      defaultSopsFile = ../secrets/users/samuel.yml;
      secrets = mkMerge [
        # SSH key - conditional
        (mkIf cfg.loadSshKey {
          samuel-ssh-key = {
            path = "${homeDirectory}/.ssh/id_ed25519";
            mode = "0400";
            owner = "${name}";
          };
        })
        # Age key - always loaded when sops is enabled
        {
          samuel-age-key = {
            path = "${homeDirectory}/.config/sops/age/keys.txt";
            mode = "0400";
            owner = "${name}";
          };
        }
        # Git secrets - conditional on git being enabled
        (mkIf cfg.homeModules.git.enable {
          samuel-git-name = { owner = "${name}"; };
          samuel-git-email = { owner = "${name}"; };
        })
      ];
    };
  };
}
