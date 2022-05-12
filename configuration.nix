# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ 
       <home-manager/nixos>  # Home manager
      ./hardware-configuration.nix # Hardware scan
    ];

  boot.kernelParams = ["mem_sleep_default=deep"];
  
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

  networking.hostName = "crowntail"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

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
  
  # Allow fingerprints in PAM login
  # security.pam.services.login.fprintAuth = true;

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.theme = "Dracula";
  services.xserver.desktopManager.plasma5.enable = true;
  
  # Hardware
  hardware.bluetooth.enable = true;

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
  hardware.pulseaudio.enable = true;

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
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  programs.htop.enable = true;

  programs.gnupg.agent = {
    enable = true;
  };

  programs.kdeconnect.enable = true;

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  services.openssh.enable = false;

  location.provider = "geoclue2";
  services.redshift = {
    enable = true;
    temperature = {
      night = 3700;
      day = 4500;
    };
  };

  # Open ports in the firewall.
  networking = {
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
        address = ["10.200.200.6/32"];
        dns = ["10.200.200.1"];
        listenPort = 43461;
        privateKeyFile = "/root/wg-key"; # root only readable file
        # autostart = false;  # This is added in later versions
        peers = [
          {
            publicKey = "LgHhvu81WJhk0plzAtTTjEmpsPLuhj7JcuMSeRJ/DRU=";
            presharedKeyFile = "/root/wg-psk"; # root only readable file
            allowedIPs = ["0.0.0.0/0"];
            endpoint = "51.68.44.212:43461";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  # HACK: Temp workaround to prevent wg0 to automatically start
  systemd.services.wg-quick-wg0.wantedBy = lib.mkForce [];

  # Packages
  ## Be bad but allow them
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    dracula-theme
    ripgrep
    qbittorrent
  ];

  # Security
  security.rtkit.enable = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  home-manager.users.dm = import /home/dm/nixos-config/home.nix;
  
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

