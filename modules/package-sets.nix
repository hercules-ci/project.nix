{ config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{

  options = {
    packageSets.sets = mkOption {
      description = ''
        Various package sets, defined by various modules.

        These are also available through the `sets` module argument.

        Let's look at a sample module:

        ```nix
        { lib, config, options, pkgs, sets, ... }:
        # Here `sets` will contain the package sets that your project defines.
        # Additionally, we have that pkgs == sets.nixpkgs == packageSets.sets.nixpkgs
        {
          # empty module, ready to make use of sets, config, etc.
        }
        ```
      '';
      type = types.attrsOf (types.uniq types.attrs);
    };
  };

  config = {
    _module.args.sets = config.packageSets.sets;
  };

}
