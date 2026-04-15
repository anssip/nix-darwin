Here's the bootstrap sequence for a fresh macbook-neo:

  1. Set the hostname and user account first
  The flake is pinned to hostname = "macbook-neo" and username = "anssi" (hosts/macbook-neo/flake.nix:40-41). Either configure those in macOS
  Setup Assistant, or:
  sudo scutil --set HostName macbook-neo
  sudo scutil --set LocalHostName macbook-neo
  sudo scutil --set ComputerName macbook-neo
  Make sure the user account is named anssi (or change the flake to match).

  2. Install Xcode Command Line Tools (gives you git, compilers, xcrun, etc.)
  xcode-select --install

  3. Install Nix — Determinate's installer is the smoothest on macOS and enables flakes by default:
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  Then open a new terminal so nix is on PATH. (If you prefer the official installer: sh <(curl -L https://nixos.org/nix/install) and add
  experimental-features = nix-command flakes to ~/.config/nix/nix.conf.)

  4. Clone this repo
  git clone git@github.com:anssip/nix-darwin.git ~/nix-darwin-config
  cd ~/nix-darwin-config

  5. First switch — bootstraps nix-darwin itself + applies the lite profile
  make deploy-neo
  That runs sudo nix run nix-darwin -- switch --flake ./hosts/macbook-neo, which installs nix-darwin, builds the system closure (skipping
  docker/emacs-mac/terraform/php/postgres per lite = true), and activates it. Subsequent updates: same make deploy-neo.

  6. Tailscale auth (one-time) — the daemon will be running after the switch, but unauthenticated:
  sudo tailscale up

  A couple of gotchas specific to your repo

  - hosts/macbook-neo/flake.lock is not in git (we discussed this earlier — the macbook-neo commit pushed flake.nix but not the lock). On first
   make deploy-neo, nix will generate a fresh lock file from current upstream nix-darwin/nixpkgs/home-manager HEADs, so the new machine may end
   up on different input revisions than what your other Macs have pinned. To get reproducibility, either:
    - copy hosts/macbook-neo/flake.lock from your current machine before deploying, or
    - run nix flake lock ./hosts/macbook-neo here, commit it, push, and pull on neo before make deploy-neo.
  - home-manager.users.anssi is hardcoded in the flake, so the macOS user must literally be anssi. If Setup Assistant created a different short
   name, fix it before deploying or the home-manager activation will fail.
  - Per the recent tailscale refactor, macOS Remote Login is not enabled for macbook-neo (the macbook-neo commit message explicitly notes
  this). If you want to SSH into it from your other Macs over the tailnet, also turn on System Settings → General → Sharing → Remote Login by
  hand after the first deploy.