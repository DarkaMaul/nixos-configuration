{ fetchurl, lib, stdenv }@args:

let

  buildThunderbirdXpiAddon = lib.makeOverridable ({ stdenv ? args.stdenv
                                                  , fetchurl ? args.fetchurl
                                                  , pname
                                                  , version
                                                  , url
                                                  , sha256
                                                  , meta
                                                  , ...
                                                  }:
    stdenv.mkDerivation rec {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      buildCommand = ''
        mkdir -p $out
        install -v -m644 $src $out/${name}.xpi
      '';
    });

  packages = { };

in
packages // {
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
    version = "102.3.3buildid20221010.194951";
    url = "https://addons.thunderbird.net/thunderbird/downloads/file/1025319/francais_fr_language_pack-115.3.20231010.142850-tb.xpi";
    sha256 = "sha256-1Z9YOUKFWm8IfF1PBIGbwGLuZID776HIM6/nijLIGCY=";
    meta = with lib; {
      homepage = "https://addons.thunderbird.net/en-US/thunderbird/addon/tb-langpack-fr/";
      description = "Français (fr) Language Pack";
      license = lib.licenses.mpl20;
    };
  };

  french-dictionnary = buildThunderbirdXpiAddon {
    pname = "french-dictionnary";
    version = "6.3.1webext";
    url = "https://addons.thunderbird.net/thunderbird/downloads/latest/dictionnaire-fran%C3%A7ais1/addon-354872-latest.xpi";
    sha256 = "sha256-5Ty+lgrgB0LhavqwruGZC5SsRFBf6lyu70syZcv3A24=";
    meta = with lib; {
      homepage = "https://addons.thunderbird.net/fr/thunderbird/addon/dictionnaire-fran%C3%A7ais1";
      description = "Dictionnaire orthographique pour la langue française.";
      license = lib.licenses.mpl20;
    };
  };
}
