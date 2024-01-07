# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix # Hardware scan
    ];

  boot.kernelParams = [
    "mem_sleep_default=deep"

    # https://community.frame.work/t/linux-battery-life-tuning/6665/156
    "nvme.noacpi=1"

    # FIX: systemd-udevd[768]: could not read from '/sys/module/pcc_cpufreq/initstate': No such device
    "intel_pstate=active"

    # Disable IPv6
    "ipv6.disable=1"
  ];
  
  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = pkgs.lib.mkOverride 0 "ondemand";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Luks
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/370d4c74-2bbe-4cdb-87e1-f58cafe87ed3";
      preLVM = true;
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_FR.UTF-8";
  console = {
  #   font = "Lat2-Terminus16";
    keyMap = pkgs.lib.mkOverride 0 "fr";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Thermal data
  services.thermald.enable = false; # TODO(dm) error here

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  
  # Fingerprinting
  services.fprintd.enable = false;
  
  # Printing
  services.printing.enable = true;

  # Allow fingerprints in PAM login
  # security.pam.services.login.fprintAuth = true;

  # Enable the fwupd daemon for firmware updates.
  services.fwupd = {
    enable = true;
    enableTestRemote = true;
    extraRemotes = ["lvfs-testing"];
    
    # Workaround for Framework laptop
    # https://knowledgebase.frame.work/framework-laptop-bios-releases-S1dMQt6F#Linux_BIOS
    uefiCapsuleSettings = {
      DisableCapsuleUpdateOnDisk = true;
    };
  };

  services.xserver.displayManager = {
    sddm = {
      enable = true;
      theme = "Dracula";
      settings = {
        General = {
          # https://askubuntu.com/q/1293912
          InputMethod = "";
        };
      };
    };
  };
  
  services.xserver.desktopManager.plasma5.enable = true;
  
  services.tlp = {
    enable = false; # TODO(dm)
    settings = {
      TLP_DEFAULT_MODE = "BAT";
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      PCIE_ASPM_ON_BAT = "powersupersave";
    };
  };

  services.pcscd.enable = true;

  # Hardware
  hardware = {
    bluetooth = {
      enable = true;
      disabledPlugins = ["sap"];
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = "true";
        };
      };
    };

    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
  };

  # Configure keymap in X11
  services.xserver.layout = "fr";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Users management
  users.mutableUsers = false;

  users.users.dm = {
    isNormalUser = true;
    hashedPassword = "$6$ygdBQ/hGUwbEaIrX$Mgdprm9l8dID/uUZk6B4cJbvtbFmIVteDjtytKEsvvH8j/yBbC4cOdn3lT6Bav5IZlWx8/EZ2kQRqVRkskH2S/";
    home = "/home/dm";
    description = "dm";
    extraGroups = ["wheel" "networkmanager"];
    shell = pkgs.zsh;
  };

  # Programs
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
    };

    htop.enable = true;
    gnupg.agent.enable = true;
    kdeconnect.enable = true;
    zsh.enable = true;

  };

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  services.openssh.enable = false;

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
      # 43461: for WG
      # 5353: for Chromecast discovery
      allowedUDPPorts = [ 43461 5353 ];
      # Frome Chromecast streaming
      allowedUDPPortRanges = [{ from = 32768; to = 61000; }];
      allowedTCPPorts = [ 8010 ];
    };
    
    wg-quick.interfaces = {
      wg0 = {
        address = ["10.49.0.3/32"];
        dns = ["172.29.147.190"];
        # listenPort = 43461;
        privateKeyFile = "/root/wg-key"; # root only readable file
        autostart = false;  # This is added in later versions
        peers = [
          {
            publicKey = "zEOirLqlRhJy1YUNHbLs8987/UuMDijE0/bBZQMVEmg=";
            presharedKeyFile = "/root/wg-psk"; # root only readable file
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "207.154.250.54:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  # Packages
  ## Be bad but allow them
  nixpkgs.config.allowUnfree = true;

  # Security
  security.rtkit.enable = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
  
  # We like to live dangerously so be it
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

