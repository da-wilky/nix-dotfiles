{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # CLI programs
    wget
    direnv

    # Languages

    # Nix extensions

    # Development tools
  ];
}
