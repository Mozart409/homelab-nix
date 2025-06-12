set dotenv-load := true

default:
    just --choose

clear:
    clear

check: clear
    nix flake check

pinchflat: clear
    nix run nixpkgs#nixos-anywhere -- --flake .#pinchflat nixos@192.168.2.108
