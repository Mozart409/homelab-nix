set dotenv-load := true

default:
    just --choose

clear:
    clear

check: clear
    nix flake check

bootstrap-pinchflat: clear
    nix run nixpkgs#nixos-anywhere -- --flake .#pinchflat nixos@192.168.2.93

pinchflat: clear
    nixos-rebuild switch --flake .#pinchflat --target-host root@192.168.2.108
