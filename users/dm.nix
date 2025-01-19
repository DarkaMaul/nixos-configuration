{ config, pkgs, lib, inputs, outputs, agenix, nur, ... }:

let
  custom-packages = import ../pkgs pkgs;
in
{

  imports = [
    inputs.nur.hmModules.nur
    ../modules/programs/kde.nix
    inputs.agenix.homeManagerModules.age
  ];

  nixpkgs = {
    overlays = [
      # nur.overlays
      outputs.overlays.modifications
      outputs.overlays.additions
    ];
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "dm";
  home.homeDirectory = "/home/dm";

  accounts.email.accounts = {
    darkamaul = {
      primary = true;
      realName = "Alexis Challande";
      thunderbird.enable = true;
      address = "darkamaul@hotmail.fr";
      flavor = "outlook.office365.com";

      # Force OAuth-2 flow
      thunderbird.settings = id: {
        "mail.smtpserver.smtp_${id}.authMethod" = 10;
        "mail.server.server_${id}.authMethod" = 10;
      };
    };
  };

  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.ssh/id_ed25519"
    ];
    secrets = { };
  };

  home.packages = [
    # Perso
    pkgs.calibre
    pkgs.discord
    pkgs.mcomix # Comics reader
    pkgs.redshift
    pkgs.spotify
    pkgs.thunderbird
    pkgs.zbar # For reading QR codes
  ] ++ [
    # Dracula
    pkgs.dracula-theme
    custom-packages.dracula-konsole-theme
    custom-packages.dracula-icons
  ] ++ [
    # Utilities
    pkgs.p7zip
    pkgs.ripgrep
    pkgs.qbittorrent
    pkgs.vlc
    pkgs.keepassxc
    # pkgs.texlive.combined.scheme-full
    custom-packages.tail-tray
  ] ++ [
    # Dev
    pkgs.gnumake
    pkgs.python3
    # pkgs.jetbrains.pycharm-professional
  ] ++ [
    # Games
    # pkgs.mindustry
    # pkgs.forge-mtg
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
        Appearance = {
          Font = "Hack,16,-1,7,50,0,0,0,0,0";
          ColorScheme = "Dracula";
        };
        General = {
          Icon = "kded5";
          Name = "dm";
          Parent = "FALLBACK/";
        };
      };
    };
  };

  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # Ublock Origin
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
    lfs.enable = true;
    signing = {
      key = "4354FD36D28894CA";
      signByDefault = false;
    };
    extraConfig = {
      merge.conflictstyle = "diff3";
    };
  };

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "Dracula";
    };
  };

  programs.firefox = {
    enable = true;

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
          "browser.startup.page" = 3; # restore previous session
          "browser.toolbars.bookmarks.visibility" = "never"; # Never show the bookmarks toolbar
          "devtools.onboarding.telemetry.logged" = false; # Telemetry
          "extensions.pocket.enabled" = false;
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
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
        extensions = with config.nur.repos.rycee.firefox-addons; [
          tree-style-tab
          ublock-origin
          (buildFirefoxXpiAddon {
            pname = "dracula-dark-theme";
            addonId = "{b743f56d-1cc1-4048-8ba6-f9c2ab7aa54d}";
            version = "1.10.0";
            url = "https://addons.mozilla.org/firefox/downloads/file/4224518/dracula_dark_colorscheme-1.10.0.xpi";
            sha256 = "zwgwdvyNf7XERmRkjEwCkJaJbvOBBO4NP76abYKJQ+E=";
            meta = with lib; {
              description = "Dracula Dark Theme";
              license = pkgs.lib.licenses.cc-by-nc-sa-30;
              platforms = pkgs.lib.platforms.all;
            };
          })

          (buildFirefoxXpiAddon rec {
            pname = "1password_x_password_manager";
            addonId = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
            version = "8.10.46.26";
            url = "https://addons.mozilla.org/firefox/downloads/file/4355876/${pname}-${version}.xpi";
            sha256 = "sha256-3JeATByldAL6Wt9uoMx3letgdGip1rX/fm7J/f0cG0c=";
            meta = with lib; {
              description = "The best way to experience 1Password in your browser.";
              license = {
                shortName = "1pwd";
                fullName = "Service Agreement for 1Password users and customers";
                url = "https://1password.com/legal/terms-of-service/";
                free = false;
              };
              platforms = pkgs.lib.platforms.all;
            };
          })
        ];
      };
    };
  };

  programs.vscode = {
    enable = true;
    userSettings = {
      "update.mode" = "none";
      "[nix]"."editor.tabSize" = 2;
      "window.zoomLevel" = 1;
      "editor.inlineSuggest.enabled" = true;
    };
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
      dracula-theme.theme-dracula
      bbenoist.nix
      tamasfe.even-better-toml
    ];
  };

  programs.bat = {
    enable = true;
    themes = {
      dracula = {
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "sublime";
          rev = "c5de15a0ad654a2c7d8f086ae67c2c77fda07c5f";
          sha256 = "sha256-m/MHz4phd3WR56I5jfi4hMXnFf4L4iXVpMFwtd0L0XE=";
        };
        file = "Dracula.tmTheme";
      };
    };
  };

  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    compression = true;
    extraConfig = ''
      IdentityAgent "~/.1password/agent.sock"
      AddKeysToAgent yes
    '';

    matchBlocks = {
      oracle = {
        hostname = "89.168.44.80";
        user = "ubuntu";
        port = 22;
        identitiesOnly = true;
        identityFile = "${config.home.homeDirectory}/.ssh/oracle_key";
      };
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "extract"
        "git"
        "sudo"
        "z"
      ];
      theme = "dracula";
      # TODO(DM): Use overlay from overlays.modifications
      # package = overlays.modifications.oh-my-zsh;
      package = pkgs.oh-my-zsh.overrideAttrs (old: {
        postInstall = ''
          chmod +x $out/share/oh-my-zsh/themes
          ln -s ${custom-packages.dracula-zsh-theme}/dracula.zsh-theme $out/share/oh-my-zsh/themes/dracula.zsh-theme
        '';
      });
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles = {
      hm-thunderbird-dm = {
        isDefault = true;
      };
    };
  };

  home.file.".thunderbird/hm-thunderbird-dm/extensions" =
    let
      extensions = with custom-packages.thunderbird-addons; [
        dracula-theme
        french-language-pack
        french-dictionnary
      ];
    in
    pkgs.lib.mkIf (extensions != [ ]) {
      source = pkgs.buildEnv {
        name = "hm-thunderbird-extensions";
        paths = extensions;
      };
      recursive = true;
      force = true;
    };

  # Autoreload for IPython
  home.file.".ipython/profile_default/ipython_config.py".text = ''
    c.InteractiveShellApp.extensions = ["autoreload"]
    c.InteractiveShellApp.exec_lines = ["%autoreload 2"]
    
    # Use Dracula as a IPython color scheme
    c.TerminalInteractiveShell.highlighting_style = "dracula"
    c.TerminalInteractiveShell.true_color = True

    # Fix the highlights of Tracebacks
    from IPython.core.ultratb import VerboseTB
    VerboseTB._tb_highlight_style = "pastie"
  '';

  # programs.texlive = {
  #   enable = true;
  #   extraPackages = tpkgs: {
  #     inherit (tpkgs)
  #     collection-basic
  #     collection-latexrecommended
  #     latexmk
  #     synctex
  #     babel-french;
  #   };
  # };

  services = {
    redshift = {
      enable = true;
      # Paris
      latitude = "48.85";
      longitude = "2.35";
    };

    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      # enableZshIntegration = true;
    };
  };

  xdg.configFile = {
    # Add configuration for shortcuts
    "khotkeysrc".source = ../config/khotkeysrc;
    "kglobalshortcutsrc".source = ../config/kglobalshortcutsrc;
    "plasma-org.kde.plasma.desktop-appletsrc".source = ../config/plasma-org.kde.plasma.desktop-appletsrc;
  };

  xdg.dataFile = {
    # Konsole shortcuts - override Tab switching
    "kxmlgui5/konsole/konsoleui.rc".source = ../config/konsoleui.rc;
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
