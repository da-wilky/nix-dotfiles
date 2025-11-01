{ config, lib, pkgs, ... }:

with lib;

{
  options.myModules.neovim = {
    enable = mkEnableOption "Neovim text editor" // { default = true; };
    
    defaultEditor = mkOption {
      type = types.bool;
      default = true;
      description = "Set neovim as default editor";
    };
    
    vimAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Create vim alias for nvim";
    };
    
    viAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Create vi alias for nvim";
    };
    
    withPython3 = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Python 3 support";
    };
    
    colorscheme = mkOption {
      type = types.str;
      default = "vscode";
      description = "Color scheme to use";
    };
    
    showLineNumbers = mkOption {
      type = types.bool;
      default = true;
      description = "Show line numbers";
    };
    
    shiftWidth = mkOption {
      type = types.int;
      default = 2;
      description = "Number of spaces for indentation";
    };
    
    plugins = mkOption {
      type = types.listOf types.package;
      default = with pkgs.vimPlugins; [
        vscode-nvim
        colorizer
        fugitive
        nerdtree
        nvim-treesitter-refactor
        nvim-treesitter.withAllGrammars
        vim-mergetool
        vim-tmux
        vim-tmux-navigator
      ];
      description = "Vim plugins to install";
    };
    
    customRC = mkOption {
      type = types.lines;
      default = "";
      description = "Additional custom vimrc configuration";
    };
  };

  config = mkIf config.myModules.neovim.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = config.myModules.neovim.defaultEditor;
      vimAlias = config.myModules.neovim.vimAlias;
      viAlias = config.myModules.neovim.viAlias;
      withPython3 = config.myModules.neovim.withPython3;
      configure = {
        customRC = ''
          colorscheme ${config.myModules.neovim.colorscheme}
          ${optionalString config.myModules.neovim.showLineNumbers "set number"}
          set shiftwidth=${toString config.myModules.neovim.shiftWidth}
          highlight Normal guibg=none
          highlight NonText guibg=none
          highlight Normal ctermbg=none
          highlight NonText ctermbg=none
          ${config.myModules.neovim.customRC}
        '';
        packages.myVimPackage = {
          start = config.myModules.neovim.plugins;
        };
      };
    };
  };
}
