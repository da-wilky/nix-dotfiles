{ config, lib, pkgs, ... }@inputs: 

{
  programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "docker" "history" "colorize" "direnv" ];
      #	theme = "alanpeabody";
	#theme = "tonotdo";
	#theme = "tjkirch";
      };
      
      plugins = with pkgs; [
	{
	  file = "powerlevel10k.zsh-theme";
	  name = "powerlevel10k";
	  src = "${zsh-powerlevel10k}/share/zsh-powerlevel10k";
	}
	{
	  file = "p10k.zsh";
	  name = "powerlevel10k-config";
	  src = ./p10k;
	}
      ];


      initExtra = ''
        flakeinit() {
          nix flake init --template "github:da-wilky/flake-templates#$1";
        }
        commit() {
          git commit -m "$1";
        }
        nixpush() {
          cd /home/samuel/dotfiles; git add .; git commit -m "$1"; git push; cd -;
        }
      '';
      shellAliases = {
        ".." = "cd ..";
        "-" = "cd -";
        v = "nvim";
        vim = "nvim";
        nixconfig = "nvim ~/dotfiles/system/configuration.nix";
        nixprograms = "nvim ~/dotfiles/system/program.nix";
        nixgit = "nvim ~/dotfiles/modules/default/git.nix";
	nixzsh = "nvim ~/dotfiles/homes/default/zsh.nix";
	nixnvim = "nvim ~/dotfiles/modules/default/neovim.nix";
	nixflake = "nvim ~/dotfiles/flake.nix";
        nixdir = "echo \"use flake\" > .envrc && direnv allow";
        nixpull = "cd /home/samuel/dotfiles; git pull; cd -;";
	# vscodeserver = "code tunnel --accept-server-license-terms --name Homeserver";
        # builddocker = "nix build && docker load < result && rm result";
        # builddockerversion = "nix build .#version && docker load < result && rm result";
        builddocker = "nix build --no-link --print-out-paths | { read imagePath; docker load < \"$imagePath\"; }";
        builddockerversion = "nix build .#version --no-link --print-out-paths | { read imagePath; docker load < \"$imagePath\"; }";
        dup = "docker compose up -d";
        ddown = "docker compose down";
        drestart = "docker compose down && docker compose up -d";
        dlogs = "docker compose logs";
	dexec = "docker compose exec";
	dsrm = "docker stack rm";
        dsdeploy = "docker stack deploy --compose-file docker-compose.yml";
        dsservices = "docker stack services";
      };
    };
}
