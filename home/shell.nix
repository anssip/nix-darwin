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
    initContent = ''
      export NVM_DIR="$HOME/.nvm"
      export PATH="$PATH:/Applications/jdk-22.0.1.jdk/Contents/Home/bin:$HOME/bin"
      export PATH="$PATH:/Applications/jdk-22.0.1.jdk/Contents/Home/bin:$HOME/bin:$HOME/.pyenv/bin"
      export JAVA_HOME=/Applications/jdk-22.0.1.jdk/Contents/Home/

      alias vapor="php $HOME/projects/easyconferencing/vendor/bin/vapor"

      export PATH="/opt/homebrew/opt/php@8.2/bin:$PATH"
      export PATH="/opt/homebrew/opt/php@8.2/sbin:$PATH"

      export PATH="/usr/local/bin:$PATH"

      export PATH="$PATH:$HOME/go/bin"

      export PATH="$PATH:$HOME/.local/bin"

      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

      eval "$(pyenv init -)"

      source "$HOME/.passlane/completions.zsh"

      # forge zsh integration (equivalent to `forge zsh setup`)
      if command -v forge >/dev/null 2>&1; then
        eval "$(forge zsh plugin)"
        eval "$(forge zsh theme)"
      fi
    '';
  };

  home.shellAliases = {
    ll = "ls -alh";
  };

}
