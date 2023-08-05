{
  description = "spicetify nix";

  inputs = {
    spicetify-themes = {
      url = "github:alindl/spicetify-themes";
      flake = false;
    };
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, spicetify-themes }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      config.allowAliases = true;
    };
    spotify-unwrapped = pkgs.spotify;
  in rec {
    packages.x86_64-linux = {
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
  };
}
