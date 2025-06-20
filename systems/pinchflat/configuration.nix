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
    homeMode = "0750";
  };
  users.groups.pinchflat = {};

  users.users.syncthing = {
    extraGroups = ["pinchflat"];
  };

  services.pinchflat = {
    enable = true;
    port = 8945;
    # mediaDir = "/var/lib/pinchflat/youtube";
    mediaDir = "/srv/pinchflat/youtube";
    secretsFile = "/root/pinchflat.secret";
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d /srv 0755 root root - -"
    "d /srv/pinchflat 0755 pinchflat pinchflat - -"
    "d /srv/pinchflat/youtube 0775 pinchflat pinchflat - -"
  ];

  systemd.services.pinchflat = {
    after = ["systemd-tmpfiles-setup.service"];
    wants = ["systemd-tmpfiles-setup.service"];
  };

  # activation script to ensure dir permissions
  system.activationScripts.ensurePinchflatDirectories = {
    deps = ["users" "groups"];
    text = ''
      # Ensure /srv exists and is writable
      mkdir -p /srv
      chmod 755 /srv

      # Create pinchflat directories with correct ownership
      mkdir -p /srv/pinchflat/youtube
      chown -R pinchflat:pinchflat /srv/pinchflat
      chmod 755 /srv/pinchflat
      chmod 775 /srv/pinchflat/youtube

      echo "Pinchflat directories created and permissions set."
    '';
  };

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

  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;
    systemService = true;
    overrideDevices = false;
    overrideFolders = false;
    settings = {
      devices = {
        homelab = {
          addresses = [
            "tcp://192.168.2.100:51820"
          ];
          id = "NI3IJJ7-7IKX7LC-V2WGUVJ-4UIDOPB-CYR3JK7-BMOSCHC-EH3UMWD-ADC63QC";
        };
      };
      gui = {
        theme = "black";
        user = "root";
        password = "syncthing";
      };
      options = {
        localAnnounceEnabled = true;
      };
      folders = {
        "Youtube" = {
          id = "xncoh-t3m2q";
          path = "/srv/pinchflat/youtube";
          devices = ["homelab"];
          type = "sendonly";
        };
      };
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts.":2222".extraConfig = ''
      reverse_proxy http://localhost:8384
      encode zstd gzip
    '';
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443 8945 8384 2222];
  };
}
