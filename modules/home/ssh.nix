{ config, lib, pkgs, ... }:

with lib;

{
  options.myHomeModules.ssh = {
    enable = mkEnableOption "SSH client configuration" // { default = true; };
    
    identitiesOnly = mkOption {
      type = types.bool;
      default = true;
      description = "Use only identities specified in SSH config";
    };
    
    githubIdentityFile = mkOption {
      type = types.str;
      default = "~/.ssh/github";
      description = "Path to GitHub SSH identity file";
    };
    
    extraMatchBlocks = mkOption {
      type = types.attrsOf (types.attrsOf types.anything);
      default = {};
      description = "Additional SSH match blocks";
      example = {
        "example.com" = {
          hostname = "example.com";
          user = "myuser";
          port = 2222;
        };
      };
    };
  };

  config = mkIf config.myHomeModules.ssh.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "*" = {
          identitiesOnly = config.myHomeModules.ssh.identitiesOnly;
        };
        "github.com" = {
          hostname = "github.com";
          user = "git";
          port = 22;
          identityFile = config.myHomeModules.ssh.githubIdentityFile;
        };
      } // config.myHomeModules.ssh.extraMatchBlocks;
    };
  };
}
