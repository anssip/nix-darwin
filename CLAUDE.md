This repository contains configuration files for NixOS and macOS. This uses nix-darwin.

## Important files

- `flake.nix`: The root flake definition.
- `home/default.nix`: Flake for home manager applications
- `modules/apps.nix`: Homebrew installed applications
- `Makefile`: Makefile for deploying the configuration, use deploy-mb normally on this Macbook Pro

## Build Commands

- `make deploy-mb`: to be used when hostname is SF-RXKNY4KQJF
- `make deploy`: to be used when hostname is not SF-RXKNY4KQJF
