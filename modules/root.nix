{ lib, ... }:

let

  inherit (lib) mkOption types;

in
{
  options = {
    root = mkOption {
      type = types.path;
      description = ''
        The root of the project.

        This must be defined as ../. in nix/project.nix.
      '';

      # Strings are harder to accidentally add to the store.
      apply = toString;
    };
  };
}
