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
        install -v -m644 $src $out/${pname}-${version}.xpi
      '';
    });

  packages = {};

in packages // {
  inherit buildThunderbirdXpiAddon;

  dracula-theme = buildThunderbirdXpiAddon {
    pname = "dracula-thunderbird-theme";
    version = "1.0";
    url = "https://addons.thunderbird.net/thunderbird/downloads/file/1018019/dracula_theme-1.0-tb.xpi";
    sha256 = "d3bbce692cb87c471cbe7a427f1f06d4c30e0d1131c51e264f5c1a59eb76443b";
    meta = with lib; {
      homepage = "https://draculatheme.com/thunderbird";
      description = "Dracula Theme for Thunderbird";
      license = lib.licenses.cc-by-30;
    };
    
  };

  french-language-pack = buildThunderbirdXpiAddon {
    pname = "french-language-pack";
    version = "115.3.20230926.115257";
    url = "https://addons.thunderbird.net/thunderbird/downloads/latest/tb-langpack-fr/addon-640748-latest.xpi";
    sha256 = "sha256-6u8i99IPrQauXoGip7UWueKvmAoqNegMPsQnO2YgrE0=";
    meta = with lib; {
      homepage = "https://addons.thunderbird.net/en-US/thunderbird/addon/tb-langpack-fr/";
      description = "Français (fr) Language Pack";
      license = lib.licenses.mpl20;
    };
  };
}