{ stdenv, lib, buildGoModule, fetchFromGitHub, spotify, spicetify-cli, spicetify-themes, theme, colorscheme }:
stdenv.mkDerivation {
  pname = "spotify";
  inherit (spotify) version;
  src = spotify;
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

    ${spicetify-cli}/bin/spicetify-cli config current_theme ${theme}
    ${spicetify-cli}/bin/spicetify-cli config color_scheme ${colorscheme}
    cat $(${spicetify-cli}/bin/spicetify-cli -c)
    cp -R ${spicetify-themes}/${theme} /tmp/spicetify-config/spicetify/Themes/
    ${spicetify-cli}/bin/spicetify-cli backup apply || true
    ${spicetify-cli}/bin/spicetify-cli apply
    mkdir -p $out
    sed -i "s#${spotify}#$out#g" ./bin/spotify
    cp -r ./* $out
  '';
}
