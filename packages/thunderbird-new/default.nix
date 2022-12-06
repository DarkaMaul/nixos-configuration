{ fetchurl, lib, stdenv }@args:

let

  buildThunderbirdXpiAddon = lib.makeOverridable ({ stdenv ? args.stdenv
    , fetchurl ? args.fetchurl, pname, version, url, sha256, meta, ...
    }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

    buildCommand = ''
      mkdir -p $out
      install -v -m644 $src $out/${pname}-dm-2.xpi
    '';
      });

  packages = [];

in packages // {
  # inherit buildThunderbirdXpiAddon;

  dracula-theme = buildThunderbirdXpiAddon {
    pname = "dracula-thunderbird-theme";
    version = "1.0";
    url = "https://addons.thunderbird.net/thunderbird/downloads/file/1018019/dracula_theme-1.0-tb.xpi";
    sha256 = "d3bbce692cb87c471cbe7a427f1f06d4c30e0d1131c51e264f5c1a59eb76443b";
    meta = with lib; {
      homepage = "https://draculatheme.com/thunderbird";
      description = "Dracula Theme for Thunderbird";
      license = licences.cc;
    };
    
  };
}