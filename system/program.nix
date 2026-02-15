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
    jq

    # Languages

    # Nix extensions
    nixpkgs-fmt
    nixfmt-classic

    # Network
    mtr
    tcpdump
    net-tools
    dnsutils

    # Development tools
  ];
}
