{ pkgs, ...}:
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

    # CLI programs

    # Languages

    # Nix extensions

    # Development tools
    #vscode
    #vscode-fhs
    #openvscode-server
  ];
}
