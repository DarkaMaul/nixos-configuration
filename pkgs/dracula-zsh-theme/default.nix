{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "dracula-zsh-theme";

  src = fetchFromGitHub {
    owner = "dracula";
    repo = "zsh";
    rev = "v1.2.5";
    sha256 = "4lP4++Ewz00siVnMnjcfXhPnJndE6ANDjEWeswkmobg=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R dracula.zsh-theme $out/
  '';

  meta = with lib; {
    description = "Dracula Zsh Theme";
    homepage = "https://draculatheme.com/zsh";
    licence = licences.mit;
  };
}