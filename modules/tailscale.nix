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
#  Coexistence with a full-tunnel VPN (OpenVPN Connect on the work laptop,
#  NordVPN on the mini): the VPN captures traffic with `redirect-gateway
#  def1`-style 0/1 + 128.0/1 routes but never becomes the macOS primary
#  service, so `State:/Network/Global/IPv4` still reports en0 while en0-scoped
#  egress is dead (EHOSTUNREACH). tailscaled binds every outgoing socket to
#  that primary interface, so control-plane, DERP and STUN dials all fail and
#  the node goes offline for as long as the VPN is up.
#
#  TS_BIND_TO_INTERFACE_BY_ROUTE asks tailscaled to pick the interface per
#  destination from the routing table instead. On its own that is not enough:
#  tailscaled resolves a destination by following the route's next hop until
#  it reaches a link-layer address, and it only recurses one level. OpenVPN's
#  point-to-point tunnel gives it two IP hops in a row (0/1 -> 172.27.232.1,
#  then 172.27.232.1 -> 172.27.233.122), so the lookup gives up with "netns:
#  error getting interface index ...: no valid address found" and falls back
#  to en0.
#
#  tailscale-vpn-route below closes that gap by repointing the tunnel
#  gateway's host route at the interface itself, which is a link-layer next
#  hop, so the recursion terminates one level in. With both pieces in place
#  tailscaled binds to the tunnel and reaches DERP through the corporate VPN.
#  Expect a relayed (not direct) path: the tunnel does not pass the UDP that
#  direct peering needs, so netcheck still fails and traffic goes over DERP.
#
#  The tailnet-side node attributes `debug-disable-bind-conn-to-interface`
#  and `...-apple-ext` (ACL policy file, nodeAttrs) were tried first and do
#  not work. They reach the node — both show up in `tailscale debug netmap`
#  under SelfNode.CapMap — but tailscaled 1.96.5 keeps binding regardless.
#  Left in the ACL as harmless in case a later release wires them up.
#
###################################################################################

{
  services.tailscale.enable = true;

  launchd.daemons.tailscaled.serviceConfig.EnvironmentVariables = {
    TS_BIND_TO_INTERFACE_BY_ROUTE = "1";
  };

  # Give tailscaled's route lookup a link-layer next hop to land on whenever a
  # full-tunnel VPN is up. Derives everything from the routing table rather
  # than hardcoding addresses, so it follows the tunnel's gateway across
  # reconnects and works for OpenVPN Connect here and NordVPN on the mini.
  launchd.daemons.tailscale-vpn-route = {
    script = ''
      set -u

      netstat=/usr/sbin/netstat
      route=/sbin/route
      awk=/usr/bin/awk

      pin_tunnel_gateway() {
        # A full-tunnel VPN announces itself with a 0/1 half-route. Columns of
        # `netstat -rn -f inet` are Destination / Gateway / Flags / Netif.
        set -- $($netstat -rn -f inet | $awk '$1 == "0/1" { print $2, $4; exit }')
        [ $# -eq 2 ] || return 0
        gw=$1
        ifc=$2

        # A link-layer next hop prints as the interface name, an IP as dotted
        # quad. Only the latter needs fixing.
        case "$gw" in
          *.*) ;;
          *) return 0 ;;
        esac

        cur=$($netstat -rn -f inet | $awk -v g="$gw" '$1 == g { print $2; exit }')
        if [ "$cur" = "$ifc" ]; then
          return 0
        fi

        if $route change -host "$gw" -interface "$ifc" >/dev/null 2>&1 ||
           $route add -host "$gw" -interface "$ifc" >/dev/null 2>&1; then
          echo "pinned tunnel gateway $gw to $ifc"
        else
          echo "failed to pin tunnel gateway $gw to $ifc"
        fi
      }

      pin_tunnel_gateway

      # A VPN connect or reconnect shows up as routing table churn. Our own
      # change re-enters here but exits on the "$cur" = "$ifc" check above, so
      # this cannot feed back on itself.
      $route -n monitor | while read -r line; do
        case "$line" in
          *RTM_ADD*|*RTM_CHANGE*|*RTM_DELETE*|*RTM_IFINFO*) pin_tunnel_gateway ;;
        esac
      done
    '';

    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/tailscale-vpn-route.log";
      StandardErrorPath = "/var/log/tailscale-vpn-route.log";
    };
  };
}
