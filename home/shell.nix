{...}: {
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "npm"
        "history"
        "node"
        "rust"
        "deno"
      ];
    };
    initExtra = ''
      export NVM_DIR="$HOME/.nvm"
      export PATH="$PATH:/Applications/jdk-22.0.1.jdk/Contents/Home/bin:/Users/anssipiirainen/bin"
      export JAVA_HOME=/Applications/jdk-22.0.1.jdk/Contents/Home/

      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    '';
  };

  home.shellAliases = {
    ll = "ls -alh";
  };

}