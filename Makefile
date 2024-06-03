deploy:
	nix build .#darwinConfigurations.anssis-macmini.system \
	   --extra-experimental-features 'nix-command flakes'

	./result/sw/bin/darwin-rebuild switch --flake .#anssis-macmini

deploy-mb:
	nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .