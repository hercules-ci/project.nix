{ config, lib, ... }:

let

  inherit (lib) mkOption types;

  # TODO functor
  recursiveRecurseIntoAttrs = v:
    if lib.isDerivation v
    then v
    else if lib.isAttrs v && v.recurseForDerivations or true
    then lib.mapAttrs (_k: recursiveRecurseIntoAttrs) v // { recurseForDerivations = true; }
    else v;

  # TODO a recursive version that terminates
  nestedAttrsOf = a:
    let
      f = b: (types.lazyAttrsOf or types.attrsOf) (types.either a b);
    in
      f (f (f (f (f (f (f (f (f (f a)))))))));

in
{
  options.checks = mkOption {
    type = nestedAttrsOf (types.nullOr types.package);
    default = {};
    description = ''
      Packages that ought be buildable, for the purpose of ensuring the quality
      of the project.
      
      These typically form a good preparation for steps like deployment.
    '';
    apply = recursiveRecurseIntoAttrs;
  };
}
