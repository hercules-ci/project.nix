{ lib, config, pkgs, ... }:

let
  inherit (lib) types mkOption;
  inherit (config) root;
  rootConfig = config;

  genericModule =
    { config, name, ... }: {
      options = {
        # We need a new interface into haskell.nix that is a submodule type.
        # This will let us expose the haskell.nix options here.
        cfg = mkOption {
          description = ''
            haskell.nix module options.

            This works mostly like a regular submodule; define options here and
            values will be available.

            See https://input-output-hk.github.io/haskell.nix/reference/modules/
          '';
          type = types.coercedTo (types.unspecified) (x: [ x ]) (types.listOf types.unspecified);
          apply = config.applyModules;
          default = [];
        };

        applyModules = mkOption {
          internal = true;
          description = ''
            Function to apply when returning cfg.
          '';
          type = types.unspecified;
          # TODO or a cabal file
          default = x: throw "Please specify a stack.yaml in packageSets.haskell-nix.${name}.stackYaml";
        };

        out.checks = mkOption {
          internal = true;
          description = ''
            Value that goes into `exports.sets.<name>`.
          '';
          type = types.attrsOf types.unspecified;
        };
      };

      config = {
        out.checks =
          lib.mapAttrs
            (
              name: pkgCfg:
                {
                  benchmarks = pkgCfg.components.benchmarks;
                  exes = pkgCfg.components.exes;
                  foreignlibs = pkgCfg.components.foreignlibs;
                  library = pkgCfg.components.library or null;
                  sublibs = pkgCfg.components.sublibs;
                  tests = pkgCfg.components.tests;
                }
            )
            (
              lib.filterAttrs
                (name: pkgCfg: pkgCfg != null && pkgCfg.isLocal or false)
                config.cfg.hsPkgs
            );
      };
    };

  stackModule =
    { config, ... }: {
      options = {
        stackYaml = lib.mkOption {
          description = ''
            Location of stack.yaml specified as a syntactic path.

            When null, no package set will be created.
          '';
          example = lib.literalExample ''../stack.yaml'';
          type = types.nullOr types.path;
          default = null;
        };
        sources.haskell-nix = lib.mkOption {
          description = ''
            Source of haskell.nix.

            Default: `niv.sources."haskell.nix"`.
          '';
          type = types.path;
        };
        sources.hackage-nix = lib.mkOption {
          description = ''
            Source of hackage.nix.

            Allows using a newer hackage.nix without updating haskell.nix.

            Default: `niv.sources."hackage.nix" or (via haskell-nix)`.
          '';
          type = types.nullOr types.path;
        };
        sources.stackage-nix = lib.mkOption {
          description = ''
            Source of stackage.nix.

            Allows using a newer stackage.nix without updating haskell.nix.

            Default: `niv.sources."stackage.nix" or (via haskell-nix)`.
          '';
          type = types.nullOr types.path;
        };
        pkgs = lib.mkOption {
          description = "Nixpkgs with haskell.nix overlays";
          default = let
            overlays =
              (import config.sources.haskell-nix).overlays ++ [
                (
                  self: super: {
                    haskell-nix = super.haskell-nix // {
                      hackageSrc = if config.sources.hackage-nix == null then super.hackageSrc else config.sources.hackage-nix;
                      stackageSrc = if config.sources.stackage-nix == null then super.stackageSrc else config.sources.stackage-nix;
                    };
                  }
                )
              ];
          in
            pkgs.extend (lib.foldr lib.composeExtensions (_: _: {}) overlays);
        };
      };
      config = lib.mkIf (config.stackYaml != null) {
        sources.haskell-nix = lib.mkDefault rootConfig.pinning.niv.sources."haskell.nix";
        sources.hackage-nix = lib.mkDefault (rootConfig.pinning.niv.sources."hackage.nix" or null);
        sources.stackage-nix = lib.mkDefault (rootConfig.pinning.niv.sources."stackage.nix" or null);

        applyModules = modules:
          let
            pkgs' = config.pkgs;
            inherit (pkgs') haskell-nix;

            stackPackageSet =
              let
                self = pkgs';
              in
                with haskell-nix; # from here on it's a bit like upstream stackProject'
                { ... }@args:
                  let
                    stack = importAndFilterProject (callStackToNix args);
                    pkg-set = mkStackPkgSet {
                      stack-pkgs = stack.pkgs;
                      pkg-def-extras = (args.pkg-def-extras or []);
                      modules = (args.modules or [])
                      ++ self.lib.optional (args ? ghc) { ghc.package = args.ghc; }
                      ++ self.lib.optional (args ? cache) (mkCacheModule args.cache);
                    };
                  in
                    pkg-set;

            it = stackPackageSet {
              src = dirOf config.stackYaml;
              stackYaml = baseNameOf config.stackYaml;
              inherit modules;
            };

          in
            it.config;
      };
    };

  submod = {
    imports = [ genericModule stackModule ];
  };

in
{

  options = {
    packageSets.haskell-nix = mkOption {
      description = "Adds haskell.nix package sets to the sets argument.";
      type = types.attrsOf (types.submodule submod);
      default = {};
    };
  };

  config = {

    # Merge haskell-nix package sets into the project's sets
    packageSets.sets = config.packageSets.haskell-nix;

    checks.sets =
      lib.mapAttrs
        (_name: submodule: submodule.out.checks)
        config.packageSets.haskell-nix;
  };

}
