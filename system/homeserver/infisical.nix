{ config, pkgs, lib, ... }:

let
  sopsFile = ../../secrets/system/homeserver.yml;
  infisicalUser = "infisical-agent";
in {
  sops.secrets = {
    infisical-client-id = {
      inherit sopsFile;
      owner = infisicalUser;
      group = infisicalUser;
      mode = "0400";
    };
    infisical-client-secret = {
      inherit sopsFile;
      owner = infisicalUser;
      group = infisicalUser;
      mode = "0400";
    };
    infisical-url = {
      inherit sopsFile;
      owner = infisicalUser;
      group = infisicalUser;
      mode = "0444";
    };
  };

  users.users.${infisicalUser} = {
    isSystemUser = true;
    group = infisicalUser;
    description = "Infisical Agent Service User";
  };
  users.groups.${infisicalUser} = { };

  # System-level systemd service
  systemd.services.infisical-agent = {
    description = "Infisical Agent - Token Refresh Daemon";
    after = [ "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      ADDRESS=$(cat ${config.sops.secrets.infisical-url.path})
      cat > /run/infisical-agent/agent.yaml <<EOF
      infisical:
        address: "$ADDRESS"
      auth:
        type: "universal-auth"
        config:
          client-id: "${config.sops.secrets.infisical-client-id.path}"
          client-secret: "${config.sops.secrets.infisical-client-secret.path}"
      sinks:
      - type: "file"
        config:
          path: "/run/infisical-agent/infisical-token"
      EOF
    '';

    serviceConfig = {
      ExecStart = "${pkgs.infisical}/bin/infisical agent --config /run/infisical-agent/agent.yaml";
      Restart = "on-failure";
      RestartSec = 5;
      User = infisicalUser;
      Group = infisicalUser;
      RuntimeDirectory = "infisical-agent";
      RuntimeDirectoryMode = "0755";
    };
  };
}
