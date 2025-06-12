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
        nixpkgs = nixpkgs.legacyPackages.x86_64-linux;
      };
      default = {pkgs, ...}: {
        environment.systemPackages = [
          pkgs.curl
        ];
      };
      pinchflat = {pkgs, ...}: {
        deployment = {
          targetHost = "pinchflat";
          targetPort = 22;
          targetUser = "amadeus";
          buildOnTarget = true;
          tags = ["homelab" "media"];
        };
        nixpkgs.system = "x86_64-linux";
        imports = [
          disko.nixosModules.disko
          ./systems/pinchflat/configuration.nix
        ];
        time.timeZone = "Europe/Berlin";
      };
    };
  };
}
