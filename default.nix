{ lib ? import ((import ./nix/sources.nix).nixpkgs + "/lib")
, ...
}:

let

  evalProject =
    { modules ? [] }: lib.evalModules {
      check = true;
      modules = builtinModules ++ modules;
    };

  builtinModules = [
    # core
    ./modules/root.nix
    ./modules/nixpkgs.nix
    ./modules/shell.nix
    ./modules/niv.nix
    ./modules/pre-commit.nix
    ./modules/activation.nix
    ./modules/package-sets.nix
    ./modules/checks.nix

    # language integrations
    ./modules/haskell-nix.nix
  ];

  libDimension = import ./lib/dimension.nix { inherit lib; };

in
{
  inherit evalProject;
  inherit (libDimension) dimension;
}
