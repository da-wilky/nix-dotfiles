{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.tmux = {
    enable = mkEnableOption "TMUX terminal multiplexer";
    
    keyMode = mkOption {
      type = types.enum [ "emacs" "vi" ];
      default = "vi";
      description = "Key mode for tmux";
    };
    
    terminal = mkOption {
      type = types.str;
      default = "screen-256color";
      description = "Terminal type";
    };
    
    enableMouse = mkOption {
      type = types.bool;
      default = true;
      description = "Enable mouse support";
    };
    
    baseIndex = mkOption {
      type = types.int;
      default = 1;
      description = "Base index for windows";
    };
    
    clock24 = mkOption {
      type = types.bool;
      default = true;
      description = "Use 24-hour clock";
    };
    
    plugins = mkOption {
      type = types.listOf types.package;
      default = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
      ];
      description = "TMUX plugins to install";
    };
  };

  config = mkIf config.myModules.tmux.enable {
    programs.tmux = {
      enable = true;
      keyMode = config.myModules.tmux.keyMode;
      terminal = if config.myModules.tmux.enableMouse 
        then "${config.myModules.tmux.terminal}\"\nset -g mouse on\n# \""
        else config.myModules.tmux.terminal;
      baseIndex = config.myModules.tmux.baseIndex;
      clock24 = config.myModules.tmux.clock24;
      plugins = config.myModules.tmux.plugins;
    };
  };
}
