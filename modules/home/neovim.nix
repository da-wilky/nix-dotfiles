{ config, lib, pkgs, ... }:

with lib;

{
  options.myHomeModules.neovim = {
    enable = mkEnableOption "Neovim configuration" // { default = true; };
    
    defaultEditor = mkOption {
      type = types.bool;
      default = true;
      description = "Set Neovim as default editor";
    };
    
    enableVimAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Create 'vim' alias for neovim";
    };
    
    enableViAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Create 'vi' alias for neovim";
    };
    
    withPython3 = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Python 3 support";
    };
    
    colorscheme = mkOption {
      type = types.str;
      default = "vscode";
      description = "Neovim colorscheme";
    };
    
    tabWidth = mkOption {
      type = types.int;
      default = 2;
      description = "Tab width (shiftwidth)";
    };
    
    enableLSP = mkOption {
      type = types.bool;
      default = true;
      description = "Enable LSP support with nvim-cmp";
    };
    
    enableSnippets = mkOption {
      type = types.bool;
      default = true;
      description = "Enable snippet support";
    };
    
    lspServers = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [ docker-compose-language-service nixd ];
      description = "LSP servers to install";
    };
    
    extraPlugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional Neovim plugins";
    };
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional Neovim configuration";
    };
    
    extraLuaConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional Lua configuration";
    };
  };

  config = mkIf config.myHomeModules.neovim.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = config.myHomeModules.neovim.defaultEditor;
      vimAlias = config.myHomeModules.neovim.enableVimAlias;
      viAlias = config.myHomeModules.neovim.enableViAlias;
      withPython3 = config.myHomeModules.neovim.withPython3;
   
      extraConfig = ''
        colorscheme ${config.myHomeModules.neovim.colorscheme}
        set number shiftwidth=${toString config.myHomeModules.neovim.tabWidth}
        highlight Normal guibg=none
        highlight NonText guibg=none
        highlight Normal ctermbg=none
        highlight NonText ctermbg=none
        
        ${config.myHomeModules.neovim.extraConfig}
      '';

      extraLuaConfig = ''
        ${optionalString config.myHomeModules.neovim.enableLSP 
          (builtins.readFile ./nvim/cmp.lua)}
        ${optionalString config.myHomeModules.neovim.enableSnippets 
          (builtins.readFile ./nvim/snippy.lua)}
        ${builtins.readFile ./nvim/docker-compose.lua}

        ${config.myHomeModules.neovim.extraLuaConfig}
      '';

      plugins = with pkgs.vimPlugins; 
        [ vscode-nvim ]
        ++ (optionals config.myHomeModules.neovim.enableLSP [
          nvim-cmp
          nvim-lspconfig
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          cmp-cmdline
        ])
        ++ (optionals config.myHomeModules.neovim.enableSnippets [
          nvim-snippy
          cmp-snippy
        ])
        ++ config.myHomeModules.neovim.extraPlugins;
    };

    home.packages = config.myHomeModules.neovim.lspServers;

    home.file.".config/nvim/snippets".source = mkIf config.myHomeModules.neovim.enableSnippets
      ./nvim/snippets;
  };
}
