{ pkgs, lib, buildGoModule, fetchFromGitHub, spotify-unwrapped, spicetify-themes }:

let
  spicetify-cli = buildGoModule rec {
    pname = "spicetify-cli";
    version = "2.6.6";

    src = fetchFromGitHub {
      owner = "khanhas";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-+fEh0x0KltrDYKIbuHV2Vxq/FslE+Ki/0eJPaWUzRCE=";
    };

    vendorSha256 = "sha256-g0RYIVIq4oMXdRZDBDnVYg7ombN5WEo/6O9hChQvOYs=";

    # used at runtime, but not installed by default
    postInstall = ''
      cp -r ${src}/jsHelper $out/bin/jsHelper
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/spicetify-cli --help > /dev/null
    '';

    meta = with lib; {
      description = "Command-line tool to customize Spotify client";
      homepage = "https://github.com/khanhas/spicetify-cli/";
      license = licenses.gpl3Plus;
      maintainers = with maintainers; [ jonringer ];
    };
  };
  spiced = pkgs.stdenv.mkDerivation {
    pname = "spotify-spiced";
    inherit (spotify-unwrapped) version;
    src = pkgs.spotify-unwrapped;
    doUnpackPhase = false;

    phases = [ "unpackPhase" "buildPhase" ];

    buildPhase = ''
      mkdir /tmp/spicetify-config
      export XDG_CONFIG_HOME=/tmp/spicetify-config
      ${spicetify-cli}/bin/spicetify-cli config spotify_path "$(pwd)"/share/spotify
      touch /tmp/spicetify-config/prefs
      ${spicetify-cli}/bin/spicetify-cli config prefs_path /tmp/spicetify-config/prefs
      ${spicetify-cli}/bin/spicetify-cli config current_theme Ziro
      ${spicetify-cli}/bin/spicetify-cli config color_scheme solarized-dark
      cat $(${spicetify-cli}/bin/spicetify-cli -c)
      cp -R ${spicetify-themes}/Ziro /tmp/spicetify-config/spicetify/Themes/
      ${spicetify-cli}/bin/spicetify-cli backup apply || true
      ${spicetify-cli}/bin/spicetify-cli apply
      mkdir -p $out
      sed -i "s#${spotify-unwrapped}#$out#g" ./bin/spotify
      cp -r ./* $out
    '';
  };
in pkgs.spotify.override { spotify-unwrapped = spiced; }
