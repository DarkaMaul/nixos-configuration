{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "dracula-konsole-theme";
  src = fetchFromGitHub {
    owner = "dracula";
    repo = "konsole";
    rev = "030486c7";
    sha256 = "sha256-siMSZ6ylw/C4aX9Iv7jNmuT1hgJPtuf6o25VwQWlbYg=";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/konsole
    cp Dracula.colorscheme $out/share/konsole
  '';

  meta = with lib; {
    description = "Dracula Theme for Konsole";
    homepage = "https://draculatheme.com/konsole";
  };
}
