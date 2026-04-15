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

    # terminal multiplexer
    tmux

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
