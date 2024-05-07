{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # CLI programs
    wget
    direnv
    git-lfs

    # Languages

    # Nix extensions

    # Development tools
  ];
}
