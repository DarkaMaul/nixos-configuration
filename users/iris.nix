{ config, pkgs, lib, inputs, outputs, agenix, nur, ... }:

let
  custom-packages = import ../pkgs pkgs ;
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
  home.homeDirectory = "/home/iris";
  home.username = "iris";

  home.packages = [
    pkgs.redshift
    pkgs.spotify
    pkgs.p7zip
    pkgs.vlc
  ];

  programs.autorandr.enable = true;

  programs.kde = {
    enable = true;
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
              extensions = with config.nur.repos.rycee.firefox-addons; [
                tree-style-tab
                ublock-origin
                ( buildFirefoxXpiAddon {
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
              ];
        };
    };
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