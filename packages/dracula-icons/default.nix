# https://github.com/knopki/devops-at-home/blob/master/pkgs/data/icons/dracula-icon-theme.nix

# https://github.com/m4thewz/dracula-icons
{ stdenv, lib, fetchzip, gtk3, pkgs }:

stdenv.mkDerivation rec {
  pname = "dracula-icon-theme";
  version = "20220512";

  src = fetchzip {
    # url from https://draculatheme.com/gtk
    url = "https://github.com/dracula/gtk/files/5214870/Dracula.zip";
    name = "icons.zip";
    sha256 = "sha256-rcSKlgI3bxdh4INdebijKElqbmAfTwO+oEt6M2D1ls0=";
    extraPostFetch = "chmod go-w $out";
  };

  nativeBuildInputs = [ gtk3 ];

  # ubuntu-mono-dark,Mint-X,elementary
  propagatedBuildInputs = with pkgs; [
    breeze-icons
    hicolor-icon-theme
    gnome-icon-theme
    papirus-icon-theme
  ];

  dontDropIconThemeCache = true;

  # Missing a few dependencies: Zafiro, elementary, ubuntu-mono-dark, Mint-X
  postPatch = ''
    substituteInPlace index.theme \
      --replace "Papirus-Dark,breeze-dark,Zafiro,ubuntu-mono-dark,Mint-X,elementary,gnome,hicolor" \
                "Papirus-Dark,breeze-dark,elementary,gnome,hicolor"
  '';

  installPhase = ''
    mkdir -p $out/share/icons/Dracula
    mv * $out/share/icons/Dracula
    gtk-update-icon-cache $out/share/icons/Dracula
  '';

  meta = with lib; {
    description = "Dracula icon theme";
    homepage = "https://draculatheme.com/gtk";
    license = licenses.lgpl3;
  };
}
