{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # CLI programs
    wget

    # Nix extensions

    # Development tools
  ];
}
