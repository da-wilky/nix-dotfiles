{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    kubectl
    (wrapHelm kubernetes-helm {
      plugins = with kubernetes-helmPlugins; [ helm-diff ];
    })
    helmfile

    # CLI programs

    # Languages

    # Nix extensions

    # Development tools
    #vscode
    #vscode-fhs
    #openvscode-server
  ];
}
