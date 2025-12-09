{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myUsers.root;

  params = {
    name = "root";
    homeDirectory = "/root";
  };

  inherit (params) name;
in {
  options.myUsers.root = {
    enableHomeManager = mkEnableOption "Home Manager for root" // {
      default = true;
    };

    homeModules = {
      git = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Git home-manager module for root";
        };
      };

      zsh = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable ZSH home-manager module for root";
        };
      };

      neovim = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Neovim home-manager module for root";
        };
      };

      ssh = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable SSH home-manager module for root";
        };

        activateGithub = mkOption {
          type = types.bool;
          default = false;
          description = "Activate SSH key for GitHub for root";
        };

        activatePibackups = mkOption {
          type = types.bool;
          default = true;
          description = "Activate SSH key for PiBackups for root";
        };
      };
    };
  };

  config = {
    # Enable ZSH (managed by home-manager module)
    programs.zsh.enable = true;

    # Set ZSH default shell for root
    users.users.${name}.shell = pkgs.zsh;

    # Setup Home for root
    home-manager.users.${name} = mkIf cfg.enableHomeManager
      ({ config, pkgs, ... }:
        import ./homes/root.nix ({
          inherit config pkgs;
          homeConfig = cfg.homeModules;
        } // params));
  };
}
