{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myUsers.pibackups;
  
  params = {
    name = "pibackups";
    homeDirectory = "/home/pibackups";
  };
  
  inherit (params) name homeDirectory;
in
{
  options.myUsers.pibackups = {
    enable = mkEnableOption "Pibackups system user";
    
    enableHomeManager = mkOption {
      type = types.bool;
      default = true;
      description = "Enable home-manager configuration";
    };
  };

  config = mkIf cfg.enable {
    # Enable ZSH (managed by home-manager module)
    programs.zsh.enable = true;
    
    # Setup User
    users.users.${name} = {
      isSystemUser = true;
      group = "${name}";
      description = "Backup User the backup services connect with.";
      # Home set here needed cuz of isSystemUser
      createHome = true;
      home = "${homeDirectory}";
      # ---
      shell = pkgs.zsh;
      packages = with pkgs; [];
      openssh.authorizedKeys.keyFiles = [ ./keys/pibackups ];
    };
    users.groups.${name} = {};

    # Setup Home
    home-manager.users.${name} = mkIf cfg.enableHomeManager (
      { config, pkgs, ... }: import ./homes/pibackups.nix ({ inherit config pkgs;} // params)
    );
  };
}
