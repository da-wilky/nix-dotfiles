{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myUsers.samuel;
  
  # Base groups that samuel should always have
  baseGroups = [ "networkmanager" "wheel" ];
  
  # Automatically collect groups from enabled modules
  moduleGroups = config.myModules.providedGroups or [];
  
  # Combine base groups with module-provided groups, plus any extra groups
  allGroups = baseGroups ++ moduleGroups ++ cfg.extraGroups;
  
  params = {
    name = "samuel";
    homeDirectory = "/home/samuel";
  };

  inherit (params) name homeDirectory;
in
{
  options.myUsers.samuel = {
    enable = mkEnableOption "Samuel user account" // { default = true; };
    
    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [];
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
      enableGit = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Git home-manager module";
      };
      
      enableZsh = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ZSH home-manager module";
      };
      
      enableNeovim = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Neovim home-manager module";
      };
      
      enableSsh = mkOption {
        type = types.bool;
        default = true;
        description = "Enable SSH home-manager module";
      };
    };
  };

  # Global option for modules to declare what groups they provide
  options.myModules.providedGroups = mkOption {
    type = types.listOf types.str;
    default = [];
    internal = true;
    description = "Groups provided by enabled modules (automatically collected)";
  };

  config = mkIf cfg.enable {
    # Enable ZSH if the home module enables it
    programs.zsh.enable = cfg.homeModules.enableZsh;

    # Create user with automatically collected groups
    users.users.${name} = {
      isNormalUser = true;
      description = "Samuel";
      extraGroups = allGroups;
      shell = if cfg.homeModules.enableZsh then pkgs.zsh else pkgs.bash;
      packages = with pkgs; [];
      openssh.authorizedKeys.keyFiles = [ ./keys/samuel ];
    };

    # Home Manager configuration
    home-manager.users.${name} = mkIf cfg.enableHomeManager (
      let
        gitNamePath = if cfg.homeModules.enableGit 
          then config.sops.secrets.samuel-git-name.path 
          else null;
        gitEmailPath = if cfg.homeModules.enableGit 
          then config.sops.secrets.samuel-git-email.path 
          else null;
      in
      {config, pkgs, ... }: import ./homes/samuel.nix ( 
        { 
          inherit config pkgs; 
          userConfig = cfg.homeModules;
          gitNameFile = gitNamePath;
          gitEmailFile = gitEmailPath;
        } // params 
      )
    );

    # Sops secrets
    sops = mkIf cfg.enableSopsSecrets {
      defaultSopsFile = ./secrets/samuel.yml;
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
        (mkIf cfg.homeModules.enableGit {
          samuel-git-name = {
            owner = "${name}";
          };
          samuel-git-email = {
            owner = "${name}";
          };
        })
      ];
    };
  };
}
