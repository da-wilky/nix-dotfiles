{ config, lib, pkgs, ... }@inputs: 

{
  programs.git = {
    enable = true;
      config = {
        init.defaultBranch = "main";
        alias = {
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
        };
      };
  };
}
