# homelab-nix

This repository contains the NixOS configuration for my homelab, managed with [Disko](https://github.com/nix-community/disko).

## Overview

The homelab setup is declared using Nix Flakes, ensuring reproducible and declarative system configurations.

## Structure

- **`flake.nix`**: Defines the Nix Flake, including inputs like `nixpkgs`, `colmena`, and `disko`, and outputs such as NixOS configurations and a Colmena hive.
- **`systems/`**: Contains the specific NixOS configurations for each machine in the homelab.
  - **`pinchflat/`**: Configuration for the `pinchflat` machine (x86_64-linux). This includes disk partitioning using Disko and system-specific settings.
- **`shell.nix`**: Provides a development shell with necessary packages.
- **`justfile`**: Contains [just](https://github.com/casey/just) commands for common tasks.
- **`cog.toml`**: Configuration file for [Conventional Commits](https://www.conventionalcommits.org/).

## Machines

### pinchflat

- **System**: `x86_64-linux`
- **Features**:
    - Disk configuration managed by Disko.
    - Tagged as `homelab` and `media`.
    - Timezone: `Europe/Berlin`.

## Deployment

## Contributing

While this is a personal homelab setup, contributions and suggestions are welcome. Please follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages.
