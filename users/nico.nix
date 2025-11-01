{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.myUsers.nico;
  
  # Base groups for nico
  baseGroups = [];
  
  # Automatically collect groups from enabled modules
  moduleGroups = config.myModules.providedGroups or [];
  
  # Combine all groups
  allGroups = baseGroups ++ moduleGroups ++ cfg.extraGroups;
in
{
  options.myUsers.nico = {
    enable = mkEnableOption "Nico user account";
    
    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional groups beyond module-provided groups";
    };
  };

  config = mkIf cfg.enable {
    # Enable ZSH for nico
    programs.zsh.enable = true;
    
    users.users.nico = {
      isNormalUser = true;
      description = "Nico";
      extraGroups = allGroups;
      shell = pkgs.zsh;
      packages = with pkgs; [];
      openssh.authorizedKeys.keyFiles = [ ./keys/nico ];
    };
  };
}
