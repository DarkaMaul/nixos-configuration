# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix # Hardware scan
    ];

  boot = {
    kernelParams = [
      "mem_sleep_default=deep"

      # https://community.frame.work/t/linux-battery-life-tuning/6665/156
      "nvme.noacpi=1"

      # FIX: systemd-udevd[768]: could not read from '/sys/module/pcc_cpufreq/initstate': No such device
      "intel_pstate=active"

      # Disable IPv6
      "ipv6.disable=1"
    ];

    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Luks
    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/370d4c74-2bbe-4cdb-87e1-f58cafe87ed3";
        preLVM = true;
      };
    };
  };

  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = pkgs.lib.mkOverride 0 "ondemand";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
    # font = "Lat2-Terminus16";
    keyMap = pkgs.lib.mkOverride 0 "fr";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  services = {

    # Thermal data
    thermald.enable = true;

    # Fingerprinting
    fprintd.enable = false;

    # Printing
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    # From https://nixos.wiki/wiki/Printing
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Tailscale
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      extraSetFlags = [ "--operator=dm" ];
    };

    # Firmware managment
    fwupd = {
      enable = true;
      extraRemotes = [ "lvfs-testing" ];

      # Workaround for Framework laptop
      # https://knowledgebase.frame.work/framework-laptop-bios-releases-S1dMQt6F#Linux_BIOS
      uefiCapsuleSettings = {
        DisableCapsuleUpdateOnDisk = true;
      };
    };

    displayManager.sddm = {
      enable = true;
      theme = "Dracula";
      settings = {
        General = {
          # https://askubuntu.com/q/1293912
          InputMethod = "";
        };
      };
      wayland.enable = true;
    };

    # Enable the X11 windowing system.
    xserver.enable = true;

    pcscd.enable = true;

    pulseaudio = {
      enable = false;
      package = pkgs.pulseaudioFull;
    };

    tlp = {
      enable = true;
      settings = {
        TLP_DEFAULT_MODE = "BAT";
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        PCIE_ASPM_ON_BAT = "powersupersave";
      };
    };

    power-profiles-daemon.enable = false;

    desktopManager.plasma6.enable = true;

    # Disable OpenSSH Daemon
    openssh.enable = false;
    pipewire = {
      enable = true;
    };

    # Configure keymap in X11
    xserver.xkb.layout = "fr";
  };

  # Secrets
  age = {
    secrets = {
      restic = {
        file = ./secrets/restic-password.age;
        owner = "dm";
      };

      restic-env = {
        file = ./secrets/restic-env.age;
        owner = "dm";
      };
    };
    identityPaths = [
      "/home/dm/.ssh/id_ed25519"
    ];
  };

  services.restic.backups = {
    backblaze = {
      passwordFile = config.age.secrets.restic.path;
      environmentFile = config.age.secrets.restic-env.path;
      paths = [
        "/home/dm/"
      ];
      exclude = [
        "/home/dm/.cache/"
        "/home/dm/.local/"
        "/home/dm/.mozilla/"

        "*.pyc"

        # Backups
        "/home/dm/Vacances/Sabbatique/Backup"
        "/home/dm/Phones/Mi4S/PhoneBackUp"

        # Random large files
        "/home/dm/Vacances/Sabbatique/Maps/"

        # A directory to work
        "/home/dm/Scratch"
      ];
      repository = "s3:s3.us-east-005.backblazeb2.com/dm-backups";
      extraBackupArgs = [
        "--one-file-system"
      ];
      user = "dm";
      initialize = true;
      timerConfig.OnCalendar = "daily";
      backupCleanupCommand = "${pkgs.curl}/bin/curl https://hc-ping.com/571e1b3a-10b2-4bcb-bdef-3c2683ab72b5";
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-yearly 10"
      ];
    };
  };

  # Hardware
  hardware = {
    bluetooth = {
      enable = true;
      disabledPlugins = [ "sap" ];
      settings = {
        General = {
          Experimental = "true";
        };
      };
    };
  };

  # Add docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  # Users management
  users.mutableUsers = false;

  users.users = {
    dm = {
      isNormalUser = true;
      hashedPassword = "$6$ygdBQ/hGUwbEaIrX$Mgdprm9l8dID/uUZk6B4cJbvtbFmIVteDjtytKEsvvH8j/yBbC4cOdn3lT6Bav5IZlWx8/EZ2kQRqVRkskH2S/";
      home = "/home/dm";
      description = "dm";
      extraGroups = [ "wheel" "networkmanager" "docker" ];
      shell = pkgs.zsh;
    };

    iris = {
      isNormalUser = true;
      hashedPassword = "$6$0xebMERPCtNXz1EF$cK2mEocw1tyfFtG3WyD.OO9JJexJM5WBANpJBs3c0ti7z2PYDw5sfP6F1tJV2ejQloutWTCsXohlcB4ECokH20";
      home = "/home/iris";
      description = "Iris";
      shell = pkgs.zsh;
    };
  };

  # Programs
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
    };

    htop.enable = true;
    gnupg.agent.enable = true;
    zsh.enable = true;

    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "dm" ];
    };
  };

  # Open ports in the firewall.
  networking = {
    # Host name
    hostName = "crowntail";

    # Activate NetworkManager
    networkmanager.enable = true;

    # Disable IPv6
    enableIPv6 = false;

    # Use Cloudfare DNS
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    # Try to solve DHCP issues
    useDHCP = false;
    firewall = {
      enable = true;
      # 5353: for Chromecast discovery
      allowedUDPPorts = [ 5353 ];
      # Frome Chromecast streaming
      allowedUDPPortRanges = [{ from = 32768; to = 61000; }];
      allowedTCPPorts = [ 8010 ];
    };
  };

  # Packages
  ## Be bad but allow them
  nixpkgs.config.allowUnfree = true;

  # Security
  security.rtkit.enable = true;

  # Garbage collection
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
    };
    # Enable flakes and nix-command
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # # Add Cachix
  environment.systemPackages = [
    pkgs.cachix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

