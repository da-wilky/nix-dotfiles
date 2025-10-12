{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
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
