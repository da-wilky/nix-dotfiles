{ config, lib, pkgs, ... }:

with lib;

{
  options.myHomeModules.zsh = {
    enable = mkEnableOption "ZSH shell configuration" // { default = true; };
    
    enableAutosuggestions = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ZSH autosuggestions";
    };
    
    enableSyntaxHighlighting = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ZSH syntax highlighting";
    };
    
    enableOhMyZsh = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Oh My ZSH framework";
    };
    
    enablePowerlevel10k = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Powerlevel10k theme";
    };
    
    ohMyZshPlugins = mkOption {
      type = types.listOf types.str;
      default = [ "git" "sudo" "docker" "history" "colorize" "direnv" ];
      description = "Oh My ZSH plugins to enable";
    };
    
    extraAliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional shell aliases beyond defaults";
    };
    
    extraInit = mkOption {
      type = types.lines;
      default = "";
      description = "Additional shell initialization code";
    };
  };

  config = mkIf config.myHomeModules.zsh.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = config.myHomeModules.zsh.enableAutosuggestions;
      syntaxHighlighting.enable = config.myHomeModules.zsh.enableSyntaxHighlighting;
      enableCompletion = true;
      
      oh-my-zsh = mkIf config.myHomeModules.zsh.enableOhMyZsh {
        enable = true;
        plugins = config.myHomeModules.zsh.ohMyZshPlugins;
      };
      
      plugins = with pkgs; mkIf config.myHomeModules.zsh.enablePowerlevel10k [
        {
          file = "powerlevel10k.zsh-theme";
          name = "powerlevel10k";
          src = "${zsh-powerlevel10k}/share/zsh-powerlevel10k";
        }
        {
          file = "p10k.zsh";
          name = "powerlevel10k-config";
          src = ./zsh/p10k;
        }
      ];

      initContent = ''
        flakeinit() {
          nix flake init --template "github:da-wilky/flake-templates#$1";
        }
        commit() {
          git commit -m "$1";
        }
        nixpush() {
          cd /home/samuel/dotfiles; git add .; git commit -m "$1"; git push; cd -;
        }

        unset ZSH_AUTOSUGGEST_USE_ASYNC
        
        ${config.myHomeModules.zsh.extraInit}
      '';
      
      shellAliases = {
        ".." = "cd ..";
        "-" = "cd -";
        v = "nvim";
        vim = "nvim";
        nixtemplate = "flakeinit";
        nixconfig = "nvim ~/dotfiles/system/configuration.nix";
        nixprograms = "nvim ~/dotfiles/system/program.nix";
        nixgit = "nvim ~/dotfiles/modules/default/git.nix";
        nixzsh = "nvim ~/dotfiles/modules/home/zsh.nix";
        nixnvim = "nvim ~/dotfiles/modules/home/neovim.nix";
        nixflake = "nvim ~/dotfiles/flake.nix";
        nixdir = "echo \"use flake\" > .envrc && direnv allow";
        nixpull = "cd /home/samuel/dotfiles; git pull; cd -;";
        nixgarbage = "sudo nix-collect-garbage --delete-old";
        builddocker = "nix build --no-link --print-out-paths | { read imagePath; docker load < \"$imagePath\"; }";
        builddockerversion = "nix build .#version --no-link --print-out-paths | { read imagePath; docker load < \"$imagePath\"; }";
        dc = "docker compose";
        dup = "docker compose up -d";
        ddown = "docker compose down";
        drestart = "docker compose down && docker compose up -d";
        dlogs = "docker compose logs";
        dexec = "docker compose exec";
        dsrm = "docker stack rm";
        dsdeploy = "docker stack deploy --compose-file docker-compose.yml";
        dsservices = "docker stack services";
      } // config.myHomeModules.zsh.extraAliases;
    };
  };
}
