{config, lib, pkgs, ...}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withPython3 = true;
 
    extraConfig = ''
      colorscheme vscode
      set number shiftwidth=2
      highlight Normal guibg=none
      highlight NonText guibg=none
      highlight Normal ctermbg=none
      highlight NonText ctermbg=none
    '';

    extraLuaConfig = ''
      ${builtins.readFile ./neovim/cmp.lua}
      ${builtins.readFile ./neovim/snippy.lua}
      ${builtins.readFile ./neovim/docker-compose.lua}
    '';

    plugins = with pkgs.vimPlugins; [
      vscode-nvim

      nvim-cmp
      nvim-lspconfig
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
    
      nvim-snippy
      cmp-snippy
    ];
  };

  home.packages = with pkgs; [
    docker-compose-language-service
    nixd
  ];

  home.file.".config/nvim/snippets".source = ./snippets;
}
