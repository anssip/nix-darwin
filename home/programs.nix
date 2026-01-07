{ pkgs, passlane, ... }:

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

    # misc
    cowsay
    file
    which
    tree
    wget
    curl
    bun
    yarn
    postgresql # PostgreSQL client utilities including psql

    # productivity
    glow # markdown previewer in terminal

    # Rust
    rustup

    # Go
    go

    nodePackages.pnpm
    (pkgs.hiPrio nodePackages.prettier)
    php83Packages.composer

    pyenv

    # database tools
    postgresql
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
