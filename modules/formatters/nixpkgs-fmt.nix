{ config, lib, pkgs, ... }:

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

  config = {
    pre-commit.hooks.nixpkgs-fmt = {
      inherit description;
      inherit (cfg) enable;
      entry = "${cfg.package}/bin/nixpkgs-fmt";
      files = ''\.nix$'';
    };
  };
}
