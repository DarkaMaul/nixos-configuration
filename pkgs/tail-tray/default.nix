{ pkgs ? import <nixpkgs> }:

pkgs.stdenv.mkDerivation rec {
  # Name of the derivation
  name = "tail-tray";
  version = "v0.2.6";

  nativeBuildInputs = [
    # This is needed for qt applications
    pkgs.qt6.wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    git
    cmake
    clang
    kdePackages.qtbase
    kdePackages.qttools
  ];

  # Source code
  src = pkgs.fetchFromGitHub {
    owner = "SneWs";
    repo = "tail-tray";
    rev = "7c8fa8733a3d654512cbf1e119d4fa7d07c21c2f";
    sha256 = "r5hOUy3Mqjh1BpdFNr17eknKPDZKGIB2/6b4D5gDbPs=";
  };

  configurePhase = ''
    mkdir -p build
    cd build
    mkdir --parents "$out"
    cmake -DCMAKE_INSTALL_PREFIX:PATH="$out" ../
  '';

  buildPhase = ''
    make -j"$NIX_BUILD_CORES"
  '';

  installPhase = ''
    runHook preInstall

    # Install (use DESTDIR for isolation)
    make install

    substituteInPlace $out/share/applications/${name}.desktop \
      --replace 'Exec=/usr/local/bin/tail-tray' 'Exec=${name}'
  '';
}
