{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  name = "thunderbird-extensions";
  addonName = "maxfrei@web.de";

  src = fetchurl {
      url = "https://addons.thunderbird.net/thunderbird/downloads/latest/dracula-theme-for-thunderbird/addon-987962-latest.xpi";
      sha256 = "d3bbce692cb87c471cbe7a427f1f06d4c30e0d1131c51e264f5c1a59eb76443b";
  };

  buildCommand = ''
    mkdir -p $out
    install -v -m644 $src $out/${addonName}-dm.xpi
  '';

  meta = with lib; {
    description = "Thunderbird Dracula Theme";
    homepage = "https://draculatheme.com/thunderbird";
    licence = licences.cc;
  };
}