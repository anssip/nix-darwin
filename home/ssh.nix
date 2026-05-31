{ ... }:

###################################################################################
#
#  SSH client config (~/.ssh/config).
#
#  Shared across both hosts. The keepalive + connection-reuse settings make
#  plain `ssh` to the mini survive idle periods instead of being dropped and
#  needing a fresh connection. For true resume-after-disconnect (sleep, IP
#  changes, long idle) use `mosh mini` instead — see home/programs.nix.
#
###################################################################################

{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      # Friendly alias for the mini over the tailnet (MagicDNS short name).
      "mini" = {
        hostname = "anssis-macmini-2";

        # Send a keepalive every 60s; give up only after ~5 missed replies.
        # This keeps idle sessions alive across NAT/router/Tailscale timeouts.
        serverAliveInterval = 60;
        serverAliveCountMax = 5;

        # Reuse a single TCP connection for additional sessions, and keep the
        # master open for 10 min after the last session closes so reconnects
        # are instant.
        controlMaster = "auto";
        controlPath = "~/.ssh/control-%r@%h:%p";
        controlPersist = "10m";
      };
    };
  };
}
