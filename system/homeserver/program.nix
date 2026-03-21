{ pkgs, nixpkgs-unstable, ...}:
{
  environment.systemPackages = with pkgs; [
    openssl

    # Kubernetes
    kubectl
    (wrapHelm kubernetes-helm {
      plugins = with kubernetes-helmPlugins; [ helm-diff ];
    })
    helmfile
    k9s

    # AI
    nixpkgs-unstable.claude-code

    # CLI programs
    infisical

    # Languages

    # Nix extensions

    # Development tools
    #vscode
    #vscode-fhs
    #openvscode-server
  ];
}
