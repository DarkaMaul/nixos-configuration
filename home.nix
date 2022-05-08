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
in
{
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
      (dracula-konsole)
  ];

  programs.autorandr.enable = true;

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
      dracula-zsh-theme = self.stdenv.mkDerivation {
        name = "dracula-zsh-theme";

        src = self.fetchFromGitHub {
          owner = "dracula";
          repo = "zsh";
          rev = "v1.2.5";
          sha256 = "4lP4++Ewz00siVnMnjcfXhPnJndE6ANDjEWeswkmobg=";
        };

        installPhase = ''
          mkdir -p $out
          cp -R dracula.zsh-theme $out/
        '';
      };
      oh-my-zsh = super.oh-my-zsh.overrideAttrs ( old: {
        postInstall = ''
            chmod +x $out/share/oh-my-zsh/themes
            ln -s ${self.dracula-zsh-theme}/dracula.zsh-theme $out/share/oh-my-zsh/themes/dracula.zsh-theme
        '';
      });
    }
    )
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

  # Set up the konsole profile theme to Dracula
  # TODO(dm) guard it if the konsole theme does not exists
  home.activation = {
    setKonsoleTheme = config.lib.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${pkgs.plasma5Packages.kconfig}/bin/kwriteconfig5 --file ${config.xdg.configHome}/konsolerc --group UiSettings --key "ColorScheme" "Dracula"
      $DRY_RUN_CMD ${pkgs.plasma5Packages.kconfig}/bin/kwriteconfig5 --file ${config.xdg.configHome}/konsolerc --group UiSettings --key "WindowColorScheme" "Dracula"
      $DRY_RUN_CMD ${pkgs.plasma5Packages.kconfig}/bin/kwriteconfig5 --file ${config.xdg.configHome}/konsolerc --group MainWindow --key "MenuBa" "Disabled"
    '';
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