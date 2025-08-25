deploy:
	sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --show-trace --flake .

deploy-mb:
	sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ./hosts/macbook
