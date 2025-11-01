{ config, lib, pkgs, ... }:

with lib;

{
  options.myHomeModules.git = {
    enable = mkEnableOption "Git version control" // { default = true; };
    
    userName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Git user name";
      example = "John Doe";
    };
    
    userNameFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing git user name (takes precedence over userName)";
      example = "/run/secrets/git-name";
    };
    
    userEmail = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Git user email";
      example = "john@example.com";
    };
    
    userEmailFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to file containing git user email (takes precedence over userEmail)";
      example = "/run/secrets/git-email";
    };
    
    defaultBranch = mkOption {
      type = types.str;
      default = "main";
      description = "Default branch name for new repositories";
    };
    
    enableAliases = mkOption {
      type = types.bool;
      default = true;
      description = "Enable git aliases";
    };
    
    customAliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional custom git aliases";
      example = { p = "push"; };
    };
    
    signing = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable commit signing";
      };
      
      key = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "GPG key ID for signing commits";
      };
      
      signByDefault = mkOption {
        type = types.bool;
        default = false;
        description = "Sign all commits by default";
      };
    };
    
    extraConfig = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional git configuration";
      example = { pull.rebase = true; };
    };
  };

  config = mkIf config.myHomeModules.git.enable {
    programs.git = {
      enable = true;
      
      userName = mkIf (config.myHomeModules.git.userNameFile == null && config.myHomeModules.git.userName != null) 
        config.myHomeModules.git.userName;
      
      userEmail = mkIf (config.myHomeModules.git.userEmailFile == null && config.myHomeModules.git.userEmail != null) 
        config.myHomeModules.git.userEmail;
      
      signing = mkIf config.myHomeModules.git.signing.enable {
        key = config.myHomeModules.git.signing.key;
        signByDefault = config.myHomeModules.git.signing.signByDefault;
      };
      
      extraConfig = mkMerge [
        { init.defaultBranch = config.myHomeModules.git.defaultBranch; }
        (mkIf (config.myHomeModules.git.userNameFile != null) {
          user.name = "!${pkgs.coreutils}/bin/cat ${config.myHomeModules.git.userNameFile}";
        })
        (mkIf (config.myHomeModules.git.userEmailFile != null) {
          user.email = "!${pkgs.coreutils}/bin/cat ${config.myHomeModules.git.userEmailFile}";
        })
        config.myHomeModules.git.extraConfig
      ];
      
      aliases = mkMerge [
        (mkIf config.myHomeModules.git.enableAliases {
          c = "commit";
          co = "checkout";
          st = "status";
          undo = "reset --soft HEAD^";
          wt = "worktree";
          wta = "worktree add";
          wtl = "worktree list";
          wtr = "worktree remove";
          localadd = "add --intent-to-add";
          localignore = "update-index --skip-worktree";
          localunignore = "update-index --no-skip-worktree";
        })
        config.myHomeModules.git.customAliases
      ];
    };
  };
}
