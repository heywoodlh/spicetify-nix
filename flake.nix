{
  description = "spicetify nix";

  inputs = {
    spicetify-themes = {
      url = "github:alindl/spicetify-themes";
      flake = false;
    };
    nixpkgs.url = "nixpkgs/21.11";
  };

  outputs = { self, nixpkgs, spicetify-themes }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in rec {
    packages.x86_64-linux = {
      solarizedDark = pkgs.callPackage ./spicetify.nix {
        inherit spicetify-themes;
      };
    };
  };
}
