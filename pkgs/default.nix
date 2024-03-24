# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  dracula-zsh-theme = pkgs.callPackage ./dracula-zsh-theme { };
  dracula-konsole-theme = pkgs.callPackage ./dracula-konsole-theme { };
  dracula-icons = pkgs.callPackage ./dracula-icons { };
  thunderbird-addons = pkgs.callPackage ./thunderbird-addons { };
}
