{ config, lib, pkgs, ... }:

let

  inherit (lib) mkOption literalExample types;

  cfg = config.shell;

in
{
  options.shell = {
    packages = mkOption {
      type = types.listOf types.package;
      default = [];
      example = literalExample "[ pkgs.node2nix ]";
      description = ''
        The set of packages that appear when you run
        nix-shell in your project root.
      '';
    };

    # TODO shellHook hooks

    # TODO environment variables

    shell = mkOption {
      type = types.package;
      description = ''
        The shell derivation for use by nix-shell.
      '';
    };
  };

  config = {
    shell.shell = pkgs.mkShell {
      nativeBuildInputs = cfg.packages;
    };
  };
}
