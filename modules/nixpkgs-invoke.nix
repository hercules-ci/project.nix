modArgs@{ config, options, lib, ... }:

with lib;

let
  cfg = config.nixpkgs;

  isConfig = x:
    builtins.isAttrs x || lib.isFunction x;

  optCall = f: x:
    if lib.isFunction f
    then f x
    else f;

  mergeConfig = lhs_: rhs_:
    let
      lhs = optCall lhs_ { inherit pkgs; };
      rhs = optCall rhs_ { inherit pkgs; };
    in
      recursiveUpdate lhs rhs // optionalAttrs (lhs ? packageOverrides) {
        packageOverrides = pkgs:
          optCall lhs.packageOverrides pkgs // optCall (attrByPath [ "packageOverrides" ] ({}) rhs) pkgs;
      } // optionalAttrs (lhs ? perlPackageOverrides) {
        perlPackageOverrides = pkgs:
          optCall lhs.perlPackageOverrides pkgs // optCall (attrByPath [ "perlPackageOverrides" ] ({}) rhs) pkgs;
      };

  configType = mkOptionType {
    name = "nixpkgs-config";
    description = "nixpkgs config";
    check = x:
      let
        traceXIfNot = c:
          if c x then true
          else lib.traceSeqN 1 x false;
      in
        traceXIfNot isConfig;
    merge = args: fold (def: mergeConfig def.value) {};
  };

  overlayType = mkOptionType {
    name = "nixpkgs-overlay";
    description = "nixpkgs overlay";
    check = lib.isFunction;
    merge = lib.mergeOneOption;
  };

  pkgsType = mkOptionType {
    name = "nixpkgs";
    description = "An evaluation of Nixpkgs; the top level attribute set of packages";
    check = builtins.isAttrs;
  };

  defaultPkgs =
    let
      systems = if cfg.buildSystem == null
      then { crossSystem = null; localSystem = cfg.system; }
      else { crossSystem = cfg.system; localSystem = cfg.buildSystem; };
    in
      import cfg.source {
        inherit (cfg // systems) config overlays localSystem crossSystem;
      };

in

{
  options.nixpkgs = {

    source = mkOption {
      type = types.path;
      default = modArgs.sources.nixpkgs or (builtins.throw "Please define 'nixpkgs.source' or 'nixpkgs.pkgs'.");
      description = ''
        Path to nixpkgs.

        Ignored when <code>nixpkgs.pkgs</code> is set.
      '';
      defaultText = literalExample "sources.nixpkgs";
      example = "<nixpkgs>";
    };

    config = mkOption {
      default = {};
      example = literalExample
        ''
          { allowBroken = true; allowUnfree = true; }
        '';
      type = configType;
      description = ''
        The configuration of the Nix Packages collection.  (For
        details, see the Nixpkgs documentation.)  It allows you to set
        package configuration options.

        Ignored when <code>nixpkgs.pkgs</code> is set.
      '';
    };

    overlays = mkOption {
      default = [];
      example = literalExample
        ''
          [
            (self: super: {
              openssh = super.openssh.override {
                hpnSupport = true;
                kerberos = self.libkrb5;
              };
            })
          ]
        '';
      type = types.listOf overlayType;
      description = ''
        List of overlays to use with the Nix Packages collection.
        (For details, see the Nixpkgs documentation.)  It allows
        you to override packages globally. Each function in the list
        takes as an argument the <emphasis>original</emphasis> Nixpkgs.
        The first argument should be used for finding dependencies, and
        the second should be used for overriding recipes.

        If <code>nixpkgs.pkgs</code> is set, overlays specified here
        will be applied after the overlays that were already present
        in <code>nixpkgs.pkgs</code>.
      '';
    };

    system = mkOption {
      type = types.either types.str types.attrs;
      example = "i686-linux";
      description = ''
        The platform type where the build products will be run.

        Ignored when <code>nixpkgs.pkgs</code> is set.
      '';
      default = builtins.currentSystem;
      defaultText = literalExample "builtins.currentSystem # The system type on which evaluation is running.";
    };

    buildSystem = mkOption {
      type = types.nullOr (types.either types.str types.attrs);
      example = "x86_64-linux";
      description = ''
        The platform type to build on.

        The default, null, will build on the same <code>nixpkgs.system</code>.
        This may require a remote builder or build agent running on that system type.

        Ignored when <code>nixpkgs.pkgs</code> is set.
      '';
      default = null;
    };

  };

  config = {
    nixpkgs.pkgs = lib.mkDefault defaultPkgs;
  };
}
