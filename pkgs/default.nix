# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs ? import <nixpkgs> { } }: rec {
  dracula-zsh-theme = pkgs.callPackage ./dracula-zsh-theme { };
}