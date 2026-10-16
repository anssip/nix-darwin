Install the WireGuard CLI (`wg`, `wg-quick`) on this Mac (`anssis-macmini-2`) via the repo's Homebrew integration.

**1. Declare the formula in `modules/apps.nix`**

Add one entry to the base `homebrew.brews` list (same style as the recent `docker-compose` commit — plain string with a short trailing comment):

```nix
brews = [
  "cmake"
  "flyctl" # fly.io CLI
  "gh" # Github CLI
  "jira-cli" # Jira CLI (ankitpokhrel/jira-cli)
  "firebase-cli"
  "gemini-cli"
  "wireguard-tools" # WireGuard CLI (wg, wg-quick); pulls in wireguard-go for utun support
  ...
```

No separate `wireguard-go` entry needed — the formula depends on it and Homebrew installs it automatically (verified on formulae.brew.sh; prebuilt Apple Silicon bottle available).

Placement in the **base** list (not `!lite`): it's a tiny CLI like `gh`/`flyctl`, so all three hosts get it on their next deploy; this Mac gets it immediately.

**2. Apply with `make deploy`** (the Makefile target for this machine: `sudo nix run nix-darwin ... switch --flake .#anssis-macmini-2`).

**3. Verify:** `wg --version` and `command -v wg-quick wireguard-go`.

**4. Commit** in repo style, e.g. `Add wireguard-tools for WireGuard CLI`.

**Notes / caveats**
- Usage afterwards: tunnel configs in `/usr/local/etc/wireguard/*.conf` (or `/etc/wireguard`), then `sudo wg-quick up <name>`.
- Interaction with `modules/tailscale.nix`: the `tailscale-vpn-route` daemon watches routing-table changes. A split-tunnel WireGuard config is ignored by it; a full-tunnel config (AllowedIPs `0.0.0.0/0`, which wg-quick installs as `0/1` + `128.0/1`) will be detected as a full-tunnel VPN and have its gateway pinned — which is the desired behavior (keeps Tailscale reachable). No code change needed; just something to be aware of.
- If `sudo` can't prompt for a password from this session, I'll make the edit and ask you to run `make deploy` yourself.