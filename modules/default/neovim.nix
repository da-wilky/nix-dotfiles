{ config, lib, pkgs, ... }@inputs: 

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withPython3 = true;
    configure = {
      customRC = ''
	colorscheme vscode 
	set number shiftwidth=2
	highlight Normal guibg=none
	highlight NonText guibg=none
	highlight Normal ctermbg=none
	highlight NonText ctermbg=none
	'';
      packages.myVimPackage = with pkgs.vimPlugins; {
	start = [
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
      };
    };
  };
}
