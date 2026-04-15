{ pkgs, username, ... }:

{
  # import sub modules
  imports = [
    ./programs.nix
    ./shell.nix
    ./git.nix
    ./ghostty.nix
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
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
