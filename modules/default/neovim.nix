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
	set number shiftwidth=2
	'';
      packages.myVimPackage = with pkgs.vimPlugins; {
	start = [
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
