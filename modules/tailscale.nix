{ ... }:

###################################################################################
#
#  Tailscale daemon (CLI).
#
#  Uses nix-darwin's `services.tailscale` module, which installs the package,
#  runs `tailscaled` as a LaunchDaemon, and wires up `/etc/resolver/ts.net`
#  so MagicDNS FQDNs (e.g. `host.<tailnet>.ts.net`) resolve without needing
#  "Override local DNS" in the admin panel.
#
#  After deploying for the first time, run `sudo tailscale up` once per machine
#  to authenticate into the tailnet.
#
#  Short hostnames (e.g. `anssis-macmini-2`) still require MagicDNS to be
#  enabled in the Tailscale admin console (DNS tab).
#
###################################################################################

{
  services.tailscale.enable = true;
}
