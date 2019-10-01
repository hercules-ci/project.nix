{ config, lib, options, pkgs, ... }:

let

  inherit (lib) mkOption literalExample types;

  cfg = config.formatters.nixpkgs-fmt;

  description = ''
    Nix code prettifier.

    https://github.com/nix-community/nixpkgs-fmt
  '';

in
{
  options.formatters.nixpkgs-fmt = {
    enable = mkOption {
      type = types.bool;
      description = ''
        Whether to enable nixpkgs-fmt.

        ${description}
      '';
      default = false;
    };
    package = mkOption {
      type = types.package;
      description = "Which nixpkgs-fmt package to use.";
      default = pkgs.nixpkgs-fmt;
      defaultText = literalExample "pkgs.nixpkgs-fmt";
    };
  };

  config = lib.optionalAttrs (options ? pre-commit.hooks) {
    pre-commit.hooks.nixpkgs-fmt = {
      inherit (cfg) enable;
      # TODO: upstream the update, remove this
      entry = lib.mkForce "${cfg.package}/bin/nixpkgs-fmt";
    };
  };
}
