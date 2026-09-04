{ pkgs, lib, lite ? false, ...}: {

  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  #  Heavy items are gated on `!lite` so lightweight hosts (e.g. macbook-neo)
  #  can opt out via `lite = true` in their flake's specialArgs.
  #
  ##########################################################################

  environment.systemPackages = with pkgs; [
    git
    git-lfs
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      # cleanup = "zap";
    };

    brews = [
      "cmake"
      "flyctl" # fly.io CLI
      "gh" # Github CLI
      "jira-cli" # Jira CLI (ankitpokhrel/jira-cli)
      "firebase-cli"
      "gemini-cli"
    ] ++ lib.optionals (!lite) [
      "terraform"
      "php@8.2"
      "docker-compose" # standalone docker-compose binary (Docker Desktop also provides `docker compose`)
    ];

    casks = [
      "keepassxc"
      "google-cloud-sdk"
      "ghostty"
    ] ++ lib.optionals (!lite) [
      "docker"
      "temurin@21" # Eclipse Temurin JDK 21 (LTS)
    ];
  };
}
