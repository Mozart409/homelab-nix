{
  config,
  pkgs,
  ...
}: {
  /*
     fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "btrfs";
  };
  */

  /*
     users.users.admin = {
    isNormalUser = true;
    extraGroups = ["wheel" "sudo"];
    password = "admin";
  };
  */

  # Another option would be root on the server
  security.sudo.extraRules = [
    {
      groups = ["wheel"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
    {
      users = ["amadeus" "user"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    coreutils
    pciutils
    git
    wget
    curl
    btop
    busybox
    openssl
    pwgen
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443];
  };

  services.openssh = {
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    ports = [22];
    enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHv1USrKf6yIjg8dZolm37xGysGfj18ol1KUKqsVuQHa amadeus@wotan"
  ];

  users.users.amadeus = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "docker"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHv1USrKf6yIjg8dZolm37xGysGfj18ol1KUKqsVuQHa amadeus@wotan"
    ];
  };

  services.tailscale.enable = true;
  services.prometheus.exporters.node.enable = true;
  services.promtail.enable = true;

  services.qemuGuest.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "de";

  system.stateVersion = "25.11";
}
