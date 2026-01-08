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

    activateGithub = mkOption {
      type = types.bool;
      default = false;
      description = "Activate GitHub SSH configuration";
    };

    githubIdentityFile = mkOption {
      type = types.str;
      default = "~/.ssh/github";
      description = "Path to GitHub SSH identity file";
    };

    activatePibackups = mkOption {
      type = types.bool;
      default = false;
      description = "Activate PiBackups SSH configuration";
    };

    pibackupsIdentityFile = mkOption {
      type = types.str;
      default = "~/.ssh/pibackups";
      description = "Path to PiBackups SSH identity file";
    };

    extraMatchBlocks = mkOption {
      type = types.attrsOf (types.attrsOf types.anything);
      default = { };
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
      enableDefaultConfig = false;
      matchBlocks = mkMerge [
        (mkIf config.myHomeModules.ssh.identitiesOnly {
          "*" = { identitiesOnly = true; };
        })
        (mkIf config.myHomeModules.ssh.activateGithub {
          "github.com" = {
            hostname = "github.com";
            user = "git";
            port = 22;
            identityFile = config.myHomeModules.ssh.githubIdentityFile;
          };
        })
        (mkIf config.myHomeModules.ssh.activatePibackups {
          "pi5dd" = {
            hostname = "pi5dd.netbird.selfhosted";
            user = "pibackups";
            port = 22;
            identityFile = config.myHomeModules.ssh.pibackupsIdentityFile;
          };
        })
        config.myHomeModules.ssh.extraMatchBlocks
      ];
    };
  };
}
