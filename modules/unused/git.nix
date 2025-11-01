{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.git = {
    enable = mkEnableOption "Git version control" // { default = true; };
    
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
      type = types.attrs;
      default = {};
      description = "Additional custom git aliases";
      example = { p = "push"; };
    };
  };

  config = mkIf config.myModules.git.enable {
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = config.myModules.git.defaultBranch;
        alias = mkMerge [
          (mkIf config.myModules.git.enableAliases {
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
          config.myModules.git.customAliases
        ];
      };
    };
  };
}
