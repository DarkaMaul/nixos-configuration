# From https://github.com/NobbZ/nixos-config/blob/main/packages/dracula/konsole/default.nix
# with import <nixpkgs> {};

{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  name = "dracula-konsole-theme";
  src = fetchFromGitHub {
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
}