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
    nameservers = [
      # "1.1.1.1"
      "192.168.2.38"
    ];
  };

  boot.loader.systemd-boot.enable = true;

  users.users.pinchflat = {
    isSystemUser = true;
    group = "pinchflat";
    home = "/var/lib/pinchflat";
    createHome = true;
  };
  users.groups.pinchflat = {};

  services.pinchflat = {
    enable = true;
    port = 8945;
    mediaDir = "/var/lib/pinchflat/youtube";
    secretsFile = "/root/pinchflat.secret";
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d       /var/lib/pinchflat/media 0750 pinchflat pinchflat -   -"
  ];

  # Activation script to create the pinchflat secret
  system.activationScripts.ensurePinchflatSecret = {
    deps = ["users" "groups"]; # Standard dependencies
    text = ''
      SECRET_FILE="/root/pinchflat.secret"
      # Check if the secret file already exists
      if [ ! -f "$SECRET_FILE" ]; then
        echo "Pinchflat secret file not found. Generating new secret at $SECRET_FILE..."
        # Generate a new secret using openssl.
        # openssl rand -hex 64 outputs 64 random bytes, hex-encoded into a 128-character string.
        SECRET_KEY=$(${pkgs.openssl}/bin/openssl rand -hex 64)

        # Write the secret to the file in the expected format
        echo "SECRET_KEY_BASE=$SECRET_KEY" > "$SECRET_FILE"

        # Set permissions: owner read-only.
        # Since the file is in /root/, it will be owned by root.
        chmod 0400 "$SECRET_FILE"
        echo "Pinchflat secret generated and secured at $SECRET_FILE."
      else
        echo "Pinchflat secret file $SECRET_FILE already exists. No action taken."
      fi
    '';
  };
}
