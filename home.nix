{ config, pkgs, ... }:

let 
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; };
    dracula-konsole = pkgs.stdenv.mkDerivation {
      name = "dracula-konsole-theme";
      src = pkgs.fetchFromGitHub {
        owner = "dracula";
        repo = "konsole";
        rev = "030486c7";
        sha256 = "sha256-siMSZ6ylw/C4aX9Iv7jNmuT1hgJPtuf6o25VwQWlbYg=";
      };

      phases = ["unpackPhase" "installPhase"];

      installPhase = ''
        mkdir -p $out/share/konsole
        cp Dracula.colorscheme $out/share/konsole
      '';
    };
    dracula-zsh-theme = pkgs.callPackage (import ./packages/dracula-zsh-theme) { };
    dracula-icon-theme = pkgs.callPackage (import ./packages/dracula-icons) { };
in
{

  imports = [
    ./modules/programs/kde.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "dm";
  home.homeDirectory = "/home/dm";

  nixpkgs.config.allowUnfree = true;
  home.packages = [
      pkgs.thunderbird
      pkgs.spotify
      pkgs.vlc
      pkgs.plasma-browser-integration
      pkgs.gnomecast
      pkgs.redshift
      dracula-konsole
      dracula-icon-theme
  ];

  programs.autorandr.enable = true;

  programs.kde = {
    enable = true;
    settings = {
      # Set up the konsole
      "${config.xdg.configHome}/konsolerc" = {
        MainWindow.MenuBar = "Disabled";
        UiSettings = {
          ColorScheme = "Dracula";
          WindowColorScheme = "Dracula";
        };

        "Desktop Entry".DefaultProfile = "dm.profile";
      };
      # Create a Konsole profile
      "${config.xdg.dataHome}/konsole/dm.profile" = {
        Appearance.Font = "Hack,16,-1,7,50,0,0,0,0,0";
        General = {
          Icon = "kded5";
          Name = "DM Profile";
          Parent = "FALLBACK/";
        };
      };
    };
  };

  programs.chromium = {
      enable = true;
      extensions = [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm"  # Ublock Origin
      ];
      # extraOpts = {
      #   "PasswordManagerEnabled" = false;
      #   "SyncDisabled" = true;
      #   "SpellcheckEnabled" = true;
      #   "SpellcheckLanguage" = ["fr" "en-US"];  
      # };
  };

  programs.git = {
    enable = true;
    userEmail = "darkamaul@hotmail.fr";
    userName = "dm";
  };

  programs.firefox = {
    enable = true;
    
    package = pkgs.firefox.override {
      cfg = {
        enablePlasmaBrowserIntegration = true;
      };
    };
    
    extensions = with nur.repos.rycee.firefox-addons; [
        browserpass
        plasma-integration
        tree-style-tab
        ublock-origin
        ( buildFirefoxXpiAddon {
          pname = "dracula-dark-theme";
          addonId = "{b743f56d-1cc1-4048-8ba6-f9c2ab7aa54d}";
          version = "1.9.2";
          url = "https://addons.mozilla.org/firefox/downloads/file/3834855/dracula_dark_theme-1.9.2-an+fx.xpi";
          sha256 = "eFxd7GfCeZHcGeMqHtYhmaz37g3D9lRhsikm4dZa69o=";
          meta = with lib; {
            description = "Dracula Dark Theme";
            license = pkgs.lib.licenses.cc-by-nc-sa-30;
            platforms = pkgs.lib.platforms.all;
          };
        })
      ];
    # Some info: https://gitlab.com/rycee/configurations/-/blob/master/user/firefox.nix#L47
    profiles = {
        dm = {
            isDefault = true;
            settings = {
                "beacon.enabled" = false;
                "browser.download.useDownloadDir" = false;
                "browser.newtabpage.activity-stream.feeds.telemetry" = false; # Telemetry
                "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
                "browser.newtabpage.activity-stream.showSponsored" = false;
                "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
                "browser.ping-centre.telemetry" = false; # Telemetry
                "browser.shell.checkDefaultBrowser" = false;
                "browser.tabs.crashReporting.sendReport" = false; # Telemetry
                "browser.urlbar.groupLabels.enabled" = false;
                "browser.startup.page" = 3;  # restore previous session
                "browser.toolbars.bookmarks.visibility" = "never"; # Never show the bookmarks toolbar
                "devtools.onboarding.telemetry.logged" = false; # Telemetry
                "extensions.pocket.enabled" = false;
                "identity.fxaccounts.enabled" = false;
                "network.prefetch-next" = false;
                # FIX: No-Proxy - so FF manage to reconnect on reboot
                "network.proxy.type" = 0;
                "signon.autofillForms" = false;
                "signon.rememberSignons" = false; # Disable Firefox Password Manager
                "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            };
            # From https://github.com/piroor/treestyletab/wiki/Code-snippets-for-custom-style-rules#hide-horizontal-tabs-at-the-top-of-the-window-1349-1672-2147
            userChrome = ''
                #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
                opacity: 0;
                pointer-events: none;
                }
                #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
                    visibility: collapse !important;
                }

                #sidebar-header {
                    display: none;
                }
        '';

        };
    };
  };
  
  programs.vscode = {
    enable = true;
    userSettings = {
        "update.mode" = "none";
        "[nix]"."editor.tabSize" = 2;
        "window.zoomLevel" = 2;
    };
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      dracula-theme.theme-dracula
      bbenoist.nix
    ];
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [exts.pass-otp]);
    settings = {
      PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
    };
  };

  programs.bat = {
    enable = true;
    themes = {
      dracula = builtins.readFile (pkgs.fetchFromGitHub {
        owner = "dracula";
        repo = "sublime";
        rev = "c5de15a0ad654a2c7d8f086ae67c2c77fda07c5f";
        sha256 = "sha256-m/MHz4phd3WR56I5jfi4hMXnFf4L4iXVpMFwtd0L0XE=";
      } + "/Dracula.tmTheme");
    };
  };

  programs.browserpass = {
      enable = true;
      browsers = ["firefox" ];  # TODO add chromium
  };

  nixpkgs.overlays = [
    (self: super: {
      oh-my-zsh = super.oh-my-zsh.overrideAttrs ( old: {
        postInstall = ''
            chmod +x $out/share/oh-my-zsh/themes
            ln -s ${dracula-zsh-theme}/dracula.zsh-theme $out/share/oh-my-zsh/themes/dracula.zsh-theme
        '';
      });

      gnomecast = super.gnomecast.overrideAttrs ( old: {
        # Use the last version because it has the fix we need
        src = super.fetchFromGitHub {
          owner = "keredson";
          repo = "gnomecast";
          rev = "d42d891";
          sha256 = "sha256-CJpbBuRzEjWb8hsh3HMW4bZA7nyDAwjrERCS5uGdwn8=";
        };
        
        # We need to set up the GNOMECAST_HTTP_PORT port here for the firewall
        preFixup = ''
          gappsWrapperArgs+=(
            --prefix PATH : ${super.lib.makeBinPath [ super.ffmpeg ]}
            --set GNOMECAST_HTTP_PORT 8010
          )
        '';
      });
    })
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["extract" "z" "git"];
      theme = "dracula";
    };
  };

  services.redshift = {
    enable = true;
    latitude = "48.85";
    longitude = "2.35";
  };

  xdg.configFile = {
    # Add environment variable for password manager
    "environment.d/20-password-manager.conf".text = "PASSWORD_STORE_DIR= ${config.programs.password-store.settings.PASSWORD_STORE_DIR}";
    # Add configuration for shortcuts
    "khotkeysrc".source = ./config/khotkeysrc;
    "kglobalshortcutsrc".source = ./config/kglobalshortcutsrc;
    "plasma-org.kde.plasma.desktop-appletsrc".source = ./config/plasma-org.kde.plasma.desktop-appletsrc;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}