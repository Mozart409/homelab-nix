{
  imports = [../shared.nix];

  # Use that when deploy scripts asks you for a hostname
  networking.hostName = "unifi";

  networking = {
    interfaces.ens18 = {
      ipv4.addresses = [
        {
          address = "192.168.2.140";
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

  fileSystems."/" = {
    device = "/dev/sda";
    # fsType = "ext4";
    fsType = "btrfs";
  };
  services.unifi = {
    enable = true;
    initialJavaHeapSize = 512;
    maximumJavaHeapSize = 1536;
    openFirewall = true;
  };
}
