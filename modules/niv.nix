{ config, lib, options, pkgs, ... }:

let
  inherit (lib) mkIf mkOption types literalExample;

  cfg = config.pinning.niv;

in
{
  options.pinning.niv = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable niv integration.
      '';
    };

    package = mkOption {
      type = types.package;
      description = ''
        The niv package to use.
      '';
      default = (import cfg.sources.niv { inherit pkgs; }).niv;
    };

    sources = mkOption {
      type = (types.lazyAttrsOf or types.attrsOf) (types.either types.path types.unspecified);
      description = ''
        The niv sources as imported.
      '';
      defaultText = literalExample ''
        # if config.pinning.niv.enable
        import (config.root + "/nix/sources.nix")
      '';
      default = {}; # See config.(mkIf).pinning.niv.sources
    };

    defaultSources = mkOption {
      internal = true;
      description = ''
        Where default sources are taken from.

        This is overwritten when project.nix is invoked via evalNivProject.
      '';
      defaultText = literalExample ''
        import (config.root + "/nix/sources.nix")
      '';
      default = import (config.root + "/nix/sources.nix");
    };

  };

  config = mkIf cfg.enable (
    {
      shell.packages = [
        cfg.package
      ];
      pinning.niv.sources =
        lib.mapAttrs (k: v: lib.mkDefault v) cfg.defaultSources;
      _module.args.sources = cfg.sources;
    } // lib.optionalAttrs (options ? pre-commit.excludes) {
      pre-commit.excludes = [ "nix/sources.nix$" ];
    }
  );
}
