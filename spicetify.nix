{ pkgs, lib, buildGoModule, fetchFromGitHub, spotify-unwrapped, spicetify-themes }:

let
  spicetify-cli = buildGoModule rec {
    pname = "spicetify-cli";
    version = "2.9.8";

    src = fetchFromGitHub {
      owner = "khanhas";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-juqQuoN8jcklgobp/dTI6OzbdpDWThn/xyYBAY5QtSU=";
    };

    vendorSha256 = "sha256-5EGPqSiU/Ep3yUmAzNYYxwZKPmWjl/RUO5tLVpntu6s=";

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
      ${spicetify-cli}/bin/spicetify-cli config 2>&1 > /dev/null || true
      CFG_PATH=$(${spicetify-cli}/bin/spicetify-cli -c)
      sed -i "s:^spotify_path.*:spotify_path = $(pwd)/share/spotify:" $CFG_PATH

      touch /tmp/spicetify-config/prefs
      sed -i "s:^prefs_path.*:prefs_path = /tmp/spicetify-config/prefs:" $CFG_PATH

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
