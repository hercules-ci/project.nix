{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption types;

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
      type = types.attrsOf types.package;
      description = ''
        The niv sources as imported.
      '';
      readOnly = true;
      default =
        if cfg.enable
        then import (config.root + "/nix/sources.nix")
        else {};
    };

  };

  config = mkIf cfg.enable {
    shell.packages = [
      cfg.package
    ];
    pre-commit.hooks.nixpkgs-fmt.excludes = [ "nix/sources.nix$" ];
  };
}
