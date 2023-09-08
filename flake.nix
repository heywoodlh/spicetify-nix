{
  description = "spicetify nix";

  inputs = {
    spicetify-themes = {
      url = "github:spicetify/spicetify-themes/master";
      flake = false;
    };
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    spicetify-themes,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.allowAliases = true;
        };
        spotify-unwrapped = pkgs.spotify;
      in {
        formatter = pkgs.alejandra;
        packages = rec {
          dracula = pkgs.callPackage ./spicetify.nix {
            theme = "Sleek";
            colorscheme = "dracula";
            inherit spicetify-themes;
          };
          dracula-text = pkgs.callPackage ./spicetify.nix {
            theme = "text";
            colorscheme = "dracula";
            inherit spicetify-themes;
          };
          nord = pkgs.callPackage ./spicetify.nix {
            theme = "Sleek";
            colorscheme = "nord";
            inherit spicetify-themes;
          };
          nord-text = pkgs.callPackage ./spicetify.nix {
            theme = "text";
            colorscheme = "nord";
            inherit spicetify-themes;
          };
          solarized-text = pkgs.callPackage ./spicetify.nix {
            theme = "text";
            colorscheme = "solarized";
            inherit spicetify-themes;
          };
        };
      }
    );
}
