{ config, lib, ... }:

let

  inherit (lib) mkOption types;

  # TODO functor
  recursiveRecurseIntoAttrs = v:
    if lib.isDerivation v
    then v
    else if lib.isAttrs v && v.recurseForDerivations or true # N.B. unlike nix-build, which assumes false
    then lib.mapAttrs (_k: recursiveRecurseIntoAttrs) v // { recurseForDerivations = true; }
    else v;

  nestedAttrsOf = a:
    let
      f = b: (types.lazyAttrsOf or types.attrsOf) (types.either a b);
    in
    f (f (f (f (f (f (f (f (f (f a)))))))));

in
{
  options.checks = mkOption {
    # TODO: custom type
    # bool: Accept recurseForDerivations (recurseIntoAttrs / dontRecurseIntoAttrs)
    type = nestedAttrsOf (types.nullOr (types.either types.package types.bool));
    default = { };
    description = ''
      Packages that ought be buildable, for the purpose of ensuring the quality
      of the project.
      
      These typically form a good preparation for steps like deployment.
    '';
    apply = recursiveRecurseIntoAttrs;
  };
}
