deploy:
	sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --show-trace --flake .#anssis-macmini-2

deploy-mb:
	sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ./hosts/macbook#SF-RXKNY4KQJF

deploy-neo:
	sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ./hosts/macbook-neo#macbook-neo
