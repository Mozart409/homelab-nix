{
  description = "Deploy my nix homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    colmena.url = "github:zhaofengli/colmena";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    colmena,
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
          targetHost = "pinchflat";
          targetPort = 22;
          targetUser = "amadeus";
          buildOnTarget = false;
          tags = ["homelab" "media"];
        };
        nixpkgs.system = "x86_64-linux";
        networking.hostName = name;
        /*
           imports = [
          disko.nixosModules.disko
          ./systems/pinchflat/configuration.nix
        ];
        */
        time.timeZone = "Europe/Berlin";
      };
    };
  };
}
