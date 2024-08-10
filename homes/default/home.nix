{ name, homeDirectory, useZSH ? true, ... }@i:

let
  defaultImports = [];
  addZSHImport = if useZSH then defaultImports ++ [ ./zsh.nix ] else defaultImports;
  resImports = addZSHImport;
in
{
  programs.home-manager.enable = true;

  imports = resImports;

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

