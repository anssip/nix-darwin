{ lib, hostname, ... }:

let
  # The Snowfox dev environment (~/vibe-tools/mac-dev-setup) only exists on the
  # work MacBook. Everywhere else (the mini `anssis-macmini-2`, `macbook-neo`)
  # keeps the plain nvm/pyenv setup this repo has always shipped.
  isMacbook = hostname == "SF-RXKNY4KQJF";
in
{
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
      export PATH="$PATH:/Applications/jdk-22.0.1.jdk/Contents/Home/bin:$HOME/bin"
      # On the MacBook, snowfox-env.sh only sets JAVA_HOME when unset, so this
      # one wins.
      export JAVA_HOME=/Applications/jdk-22.0.1.jdk/Contents/Home/

      alias vapor="php $HOME/projects/easyconferencing/vendor/bin/vapor"

      export PATH="/opt/homebrew/opt/php@8.2/bin:$PATH"
      export PATH="/opt/homebrew/opt/php@8.2/sbin:$PATH"

      export PATH="$PATH:$HOME/go/bin"

      export PATH="$PATH:$HOME/.local/bin"
      ${lib.optionalString (!isMacbook) ''
        export NVM_DIR="$HOME/.nvm"
        export PATH="$PATH:$HOME/.pyenv/bin"
        export PATH="/usr/local/bin:$PATH"
      ''}
      source "$HOME/.passlane/completions.zsh"

      # forge zsh integration (equivalent to `forge zsh setup`)
      if command -v forge >/dev/null 2>&1; then
        eval "$(forge zsh plugin)"
        eval "$(forge zsh theme)"
      fi

      ${
        if isMacbook
        then ''
          # Snowfox dev environment (vibe-tools/mac-dev-setup), work MacBook only.
          # Owns Homebrew shellenv, NVM_DIR + nvm, PYENV_ROOT + pyenv init,
          # the gcloud SDK bin dir (gke-gcloud-auth-plugin), JIRA_API_TOKEN and
          # ulimit -n. Sourced last so its PATH ordering and pyenv shims win.
          [ -f "$HOME/vibe-tools/mac-dev-setup/snowfox.zsh" ] && \
            source "$HOME/vibe-tools/mac-dev-setup/snowfox.zsh"
        ''
        else ''
          [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

          eval "$(pyenv init -)"
        ''
      }
      # Needs NVM_DIR, hence the placement after the nvm setup above.
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    '';
  };

  home.shellAliases = {
    ll = "ls -alh";

    # mosh into the mini and attach (or create) a persistent tmux session,
    # so work survives disconnects/sleep. Plain `mosh mini` / `ssh mini`
    # remain untouched.
    mm = "mosh mini -- tmux new -A -s main";
  };

}
