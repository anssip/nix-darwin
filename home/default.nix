{ pkgs, username, lib, ... }:

{
  # import sub modules
  imports = [
    ./programs.nix
    ./shell.nix
    ./git.nix
    ./ghostty.nix
    ./ssh.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.11";

    # Populate ~/.terminfo so ncurses finds xterm-ghostty without needing
    # TERMINFO_DIRS to be set — zsh initialises terminfo before /etc/zshenv
    # runs, so the system-wide install at /run/current-system/sw/share/terminfo
    # isn't visible during that early lookup.
    file.".terminfo".source = "${pkgs.ghostty-bin.terminfo}/share/terminfo";

    sessionVariables = {
      EDITOR = lib.mkForce "cot --wait";
    };
  };

  # Don't build the Home Manager options-reference manpage. Generating it
  # forces evaluation of every option's default, and on the current
  # HM 25.11 / Nixpkgs 26.05 combo one of those defaults
  # (i18n.inputMethod.fcitx5 -> pkgs.libsForQt5.fcitx5-with-addons) points at
  # a package that was renamed, which breaks `make deploy`. We never use the
  # generated manpage, so skip it.
  manual.manpages.enable = false;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
