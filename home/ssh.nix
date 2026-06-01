{ lib, hostname, ... }:

###################################################################################
#
#  SSH client config (~/.ssh/config).
#
#  Shared across all hosts. The keepalive + connection-reuse settings make
#  plain `ssh` to the mini survive idle periods instead of being dropped and
#  needing a fresh connection. For true resume-after-disconnect (sleep, IP
#  changes, long idle) use `mosh mini` instead — see home/programs.nix.
#
###################################################################################

let
  # The mini authenticates to GitHub with a dedicated passphraseless key so
  # `git push` works in headless (ssh/mosh/tmux) sessions, which have no
  # ssh-agent — unlike the GUI login session, where the passphrased id_rsa is
  # auto-loaded from the Keychain. Scoped to the mini only: forcing this
  # IdentityFile + IdentitiesOnly elsewhere (e.g. neo) would break GitHub auth
  # there, since neo pushes via its agent key.
  isMini = hostname == "anssis-macmini-2";
in
{
  programs.ssh = {
    enable = true;

    matchBlocks = lib.optionalAttrs isMini {
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519_github";
        identitiesOnly = true;
      };
    } // {
      # Friendly alias for the mini over the tailnet. Use the full MagicDNS
      # FQDN: it resolves via /etc/resolver/ts.net regardless of search-domain
      # config. Note the tailnet node name is `anssis-macmini` (the system
      # hostname is `anssis-macmini-2`, but it joined the tailnet as the former).
      "mini" = {
        hostname = "anssis-macmini.tailcb0f0e.ts.net";

        # Send a keepalive every 60s; give up only after ~5 missed replies.
        # This keeps idle sessions alive across NAT/router/Tailscale timeouts.
        serverAliveInterval = 60;
        serverAliveCountMax = 5;

        # Reuse a single TCP connection for additional sessions, and keep the
        # master open for 10 min after the last session closes so reconnects
        # are instant. Passed as raw ssh_config keys via extraOptions so this
        # works across home-manager versions (the named controlMaster options
        # don't exist in the older home-manager the root flake pins).
        extraOptions = {
          ControlMaster = "auto";
          ControlPath = "~/.ssh/control-%r@%h:%p";
          ControlPersist = "10m";
        };
      };
    };
  };
}
