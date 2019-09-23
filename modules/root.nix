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

        When reading the option, take care not to accidentally add it to
        the store in its entirety. In particular, use

            config.root + "/somepath"

        and avoid interpolation, toString etc until you want to add paths
        to the store.
      '';
    };
  };
}