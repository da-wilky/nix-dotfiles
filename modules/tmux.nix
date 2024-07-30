{ config, lib, pkgs, ... }@inputs: 

{
  programs.tmux = {
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
}
