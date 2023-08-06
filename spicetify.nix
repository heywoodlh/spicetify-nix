{
  stdenv,
  lib,
  buildGoModule,
  fetchFromGitHub,
  spotify,
  spicetify-cli,
  spicetify-themes,
  theme,
  colorscheme,
}:
stdenv.mkDerivation {
  pname = "spotify";
  inherit (spotify) version;
  src = spotify;
  doUnpackPhase = false;

  phases = ["unpackPhase" "buildPhase"];

  buildPhase = ''
    mkdir -p $(pwd)/spicetify-config
    touch $(pwd)/spicetify-config/prefs
    if [[ $(uname) == "Linux" ]]
    then
      export XDG_CONFIG_HOME=$(pwd)/spicetify-config
      CFG_PATH=$(${spicetify-cli}/bin/spicetify-cli -c)
      ${spicetify-cli}/bin/spicetify-cli config 2>&1 > /dev/null || true
      sed -i "s:^spotify_path.*:spotify_path = $(pwd)/share/spotify:" $CFG_PATH
      sed -i "s:^prefs_path.*:prefs_path = $(pwd)/spicetify-config/prefs:" $CFG_PATH
      cp -R ${spicetify-themes}/${theme} $(pwd)/spicetify-config/spicetify/Themes/
    fi

    if [[ $(uname) == "Darwin" ]]
    then
      export HOME=$(pwd)/spicetify-config
      CFG_PATH=$(${spicetify-cli}/bin/spicetify-cli -c)
      ${spicetify-cli}/bin/spicetify-cli config 2>&1 > /dev/null || true
      mkdir -p $(pwd)/spicetify-config/Library/Application\ Support/Spotify
      mkdir -p $(pwd)/spicetify-config/.config/spicetify/
      sed -i "s:^spotify_path.*:spotify_path = $(pwd)/Applications/Spotify.app/Contents/Resources:" $CFG_PATH
      ls Applications/Spotify.app/Contents/MacOS/ > $(pwd)/testing.txt
      sed -i "s:^prefs_path.*:prefs_path = $(pwd)/spicetify-config/prefs:" $CFG_PATH
      cp -R ${spicetify-themes}/${theme} $(pwd)/spicetify-config/.config/spicetify/Themes/
    fi

    ${spicetify-cli}/bin/spicetify-cli config current_theme ${theme}
    ${spicetify-cli}/bin/spicetify-cli config color_scheme ${colorscheme}
    cat $(${spicetify-cli}/bin/spicetify-cli -c)
    ${spicetify-cli}/bin/spicetify-cli backup apply || true
    ${spicetify-cli}/bin/spicetify-cli apply

    # Patch spotify wrapper (Linux)
    if [[ $(uname) == "Linux" ]]
    then
      sed -i "s#${spotify}#$out#g" ./bin/spotify
    fi

    # Create spotify wrapper (MacOS)
    if [[ $(uname) == "Darwin" ]]
    then
      mkdir -p $out/bin
      printf "#!/usr/bin/env bash\n$out/Applications/Spotify.app/Contents/MacOS/Spotify" > $out/bin/spotify
      chmod +x $out/bin/spotify
    fi

    mkdir -p $out
    cp -r ./* $out

  '';
}
