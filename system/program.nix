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
    openssl

    # Languages

    # Nix extensions
    nixpkgs-fmt
    nixfmt-classic

    # Development tools
  ];
}
