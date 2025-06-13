{
  description = "Deploy my nix homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    colmena.url = "github:zhaofengli/colmena";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # For the devShell
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    colmena,
    flake-utils,
    ...
  }: {
    nixosConfigurations.pinchflat = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./systems/pinchflat/configuration.nix
      ];
    };

    colmenaHive = colmena.lib.makeHive {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [];
        };
      };
      default = {pkgs, ...}: {
        environment.systemPackages = [
          pkgs.curl
        ];
      };
      pinchflat = {
        pkgs,
        name,
        nodes,
        ...
      }: {
        deployment = {
          # targetHost = "pinchflat";
          targetHost = "192.168.2.108";
          targetPort = 22;
          targetUser = "amadeus";
          buildOnTarget = false;
          tags = ["homelab" "media"];
        };
        nixpkgs.system = "x86_64-linux";
        networking.hostName = name;

        boot.loader.grub.device = "/dev/sda";
        fileSystems."/" = {
          device = "/dev/sda1";
          fsType = "ext4";
        };

        imports = [
          disko.nixosModules.disko
          ./systems/pinchflat/configuration.nix
        ];

        time.timeZone = "Europe/Berlin";
      };
    };
  };
}
