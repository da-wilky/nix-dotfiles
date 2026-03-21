{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myHomeModules.gh;
in
{
  options.myHomeModules.gh = {
    enable = mkEnableOption "GitHub CLI (gh)";

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional gh aliases merged with defaults";
    };
  };

  config = mkIf cfg.enable {
    programs.gh = {
      enable = true;

      settings.aliases = {
        co = "pr checkout";
        pv = "pr view";
        pl = "pr list";
        pc = "pr create";
        pm = "pr merge";
        pe = "pr edit";
        pecopilot = "pr edit --add-reviewer \"copilot-pull-request-reviewer[bot]\"";
        il = "issue list";
        iv = "issue view";
        ic = "issue create";
        rl = "repo list";
        rv = "repo view";
        rc = "repo clone";
      } // cfg.aliases;
    };
  };
}
