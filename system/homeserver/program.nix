{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # CLI programs

    # Languages

    # Nix extensions

    # Development tools
    vscode
    vscode-fhs
    #openvscode-server
  ];
}
