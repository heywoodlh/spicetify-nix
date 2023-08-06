{
  description = "spicetify nix";

  inputs = {
    spicetify-themes = {
      url = "github:alindl/spicetify-themes";
      flake = false;
    };
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    spicetify-themes,
    flake-utils
  }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowAliases = true;
      };
      spotify-unwrapped = pkgs.spotify;
    in {
      formatter = pkgs.alejandra;
      packages = rec {
        solarizedDark = pkgs.callPackage ./spicetify.nix {
          theme = "Ziro";
          colorscheme = "solarized-dark";
          inherit spicetify-themes;
        };
        nord = pkgs.callPackage ./spicetify.nix {
          theme = "Sleek";
          colorscheme = "nord";
          inherit spicetify-themes;
        };
      };
    }
  );
}
