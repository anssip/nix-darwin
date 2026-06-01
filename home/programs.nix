{ pkgs, lib, passlane, lite ? false, ... }:

{
  home.packages = with pkgs; [
    nnn # terminal file manager

    # archives
    atool # A script for managing file archives of various types

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    fzf # A command-line fuzzy finder

    aria2 # A lightweight multi-protocol & multi-source command-line download utility

    # mobile shell: SSH replacement whose UDP session survives idle, sleep,
    # and network changes, so connections to the mini resume without
    # re-establishing them by hand. Installed on both ends (shared module),
    # which is required: `mosh` needs `mosh-server` present on the remote.
    mosh

    # misc
    cowsay
    file
    which
    tree
    wget
    curl
    bun
    yarn

    # productivity
    glow # markdown previewer in terminal

    # Go
    go

    pnpm
    (pkgs.hiPrio prettier)
    php83Packages.composer

    pyenv
  ] ++ lib.optionals (!lite) [
    # Rust
    rustup

    # database tools
    postgresql # PostgreSQL client utilities including psql
  ];

  programs = {
    # terminal multiplexer. mouse = true enables two-finger touchpad
    # scrolling of the scrollback buffer (scroll up enters copy-mode).
    # This must be set wherever tmux *runs* — i.e. the mini, which gets
    # this shared home config too.
    tmux = {
      enable = true;
      mouse = true;
    };

    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
