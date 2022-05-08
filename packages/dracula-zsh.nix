with import <nixpkgs> {};

# { lib, pkgs }:

pkgs.stdenv.mkDerivation {
  name = "dracula-zsh-theme";

  src = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "zsh";
    rev = "v1.2.5";
    sha256 = "4lP4++Ewz00siVnMnjcfXhPnJndE6ANDjEWeswkmobg=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R dracula.zsh-theme $out/
  '';
  #   ln -s dracula.zsh-theme ${pkgs.oh-my-zsh}/share/oh-my-zsh/themes/
  #   # install -Dm0644 dracula.zsh-theme $out/share/zsh/themes/lambda-mod.zsh-theme
  # '';

  meta = with lib; {
    description = "Dracula theme for ZSH";
    homepage = https://github.com/dracula/zsh.git;
    # license = licenses.mit;
    # platforms = platforms.linux;
  };
}
