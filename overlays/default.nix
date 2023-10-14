{inputs, ...}: rec {
  
  additions = final: _prev: import ../pkgs {pkgs = final;};

  modifications = final: prev: {

    oh-my-zsh = prev.oh-my-zsh.overrideAttrs ( old: {
      postInstall = ''
        chmod +x $out/share/oh-my-zsh/themes
        ln -s ${prev.dracula-zsh-theme}/dracula.zsh-theme $out/share/oh-my-zsh/themes/dracula.zsh-theme
      '';
    });

    gnomecast = prev.gnomecast.overrideAttrs ( old: {
      # Use the last version because it has the fix we need
      src = prev.fetchFromGitHub {
        owner = "keredson";
        repo = "gnomecast";
        rev = "d42d891";
        sha256 = "sha256-CJpbBuRzEjWb8hsh3HMW4bZA7nyDAwjrERCS5uGdwn8=";
      };
      
      # We need to set up the GNOMECAST_HTTP_PORT port here for the firewall
      preFixup = ''
        gappsWrapperArgs+=(
          --prefix PATH : ${prev.lib.makeBinPath [ prev.ffmpeg ]}
          --set GNOMECAST_HTTP_PORT 8010
        )
      '';
    });

    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };


}