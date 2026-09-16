deploy:
	sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --show-trace --flake .#anssis-macmini-2

deploy-mb:
	sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ./hosts/macbook#SF-RXKNY4KQJF

deploy-neo:
	sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ./hosts/macbook-neo#macbook-neo

# Bump flake.lock (nixpkgs, home-manager, nix-darwin, passlane) for one host.
# Each host has its own lock: run the matching update target, then its deploy target.
# To move a single input only: nix flake update nixpkgs-darwin --flake ./hosts/macbook
update:
	nix flake update --flake .

update-mb:
	nix flake update --flake ./hosts/macbook

update-neo:
	nix flake update --flake ./hosts/macbook-neo
