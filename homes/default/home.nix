{ name, homeDirectory, useZSH ? true, useNVIM ? true, ... }@i:

let
  myImports = []
    ++ (if useZSH then [ ./zsh.nix ] else [])
    ++ (if useNVIM then [ ./neovim.nix ] else []);
in
{
  programs.home-manager.enable = true;

  imports = myImports;

  # paths it should manage.
  home.username = name;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";
}

