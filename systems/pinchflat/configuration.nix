{
  modulesPath,
  lib,
  pkgs,
  ...
} @ args: {
  imports = [
    ../shared.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  # Use that when deploy scripts asks you for a hostname
  networking.hostName = "pinchflat";

  networking = {
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "192.168.2.108";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.2.1";
      interface = "ens18";
    };
  };

  boot.loader.systemd-boot.enable = true;

  services.pinchflat = {
    enable = true;
    port = 8945;
    mediaDir = "/root/youtube";
    secretsFile = "/root/pinchflat.secret";
    openFirewall = true;
  };
}
