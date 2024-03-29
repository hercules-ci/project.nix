rec {
  /*
    Minimal arguments:

    sources         By convention: import ./sources.nix
    An attribute set of sources.
    modules         By convention: [ ./project.nix ]
    The project.nix configuration modules.
  */
  evalNivProject =
    { modules
    , sources
    , nixpkgs ? sources.nixpkgs
    , lib ? import (nixpkgs + "/lib")
    , specialArgs ? { }
    }:
    let
      out = evalProject {
        inherit lib;
        modules = modules ++ [
          {
            config.pinning.niv.enable = true;
            config.pinning.niv.defaultSources = sources;
          }
        ];
        specialArgs = specialArgs // {
          defaultSources = sources;
        };
      };
    in
    out;

  evalProject =
    args@
    { modules
    , specialArgs ? { }
    , nixpkgs ? <nixpkgs>
    , lib ? import (nixpkgs + "/lib")
    }:
    let
      out = lib.evalModules {
        check = true;
        modules = builtinModules ++ modules ++ lib.optional (args ? nixpkgs) { config.nixpkgs.source = nixpkgs; };
        specialArgs = specialArgs;
      };
    in
    out;

  builtinModules = [
    # core
    ./modules/root.nix
    ./modules/nixpkgs.nix
    ./modules/nixpkgs-invoke.nix
    ./modules/shell.nix
    ./modules/niv.nix
    ./modules/pre-commit.nix
    ./modules/activation.nix
    ./modules/package-sets.nix
    ./modules/checks.nix

    # language integrations
    ./modules/haskell-nix.nix
  ];

  # If you're looking for `dimension`, please import lib/dimension.nix directly.
}
