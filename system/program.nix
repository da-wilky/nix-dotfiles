{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # CLI programs
    wget
    direnv
    git
    git-lfs
    age
    sops
    htop
    btop

    # Languages

    # Nix extensions
    nixpkgs-fmt

    # Development tools
  ];
}
