{ config, lib, pkgs, ... }@inputs: 

{
  programs.git = {
    enable = true;
      config = {
        init.defaultBranch = "main";
        alias = {
          ci = "commit";
          co = "checkout";
          st = "status";
          undo = "reset --soft HEAD^";

	  localadd = "add --intent-to-add";
          localignore = "update-index --skip-worktree";
          localunignore = "update-index --no-skip-worktree";
        };
      };
  };
}
