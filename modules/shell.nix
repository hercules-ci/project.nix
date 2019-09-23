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

    hooks = mkOption {
      type = types.listOf types.str;
      description = ''
        bash snippets to run when entering the project's nix-shell.
      '';
      default = [];
      example = [''
          if ! type git >/dev/null; then
            echo 1>&2 "git command not found! Please install git on your system or user profile";
          fi
        ''
      ];
    };

    # TODO: can we specify merge functions in an extensible way?
    extraAttrs = mkOption {
      type = types.attrsOf types.str;
      description = ''
        Extra variables to set in the project's nix-shell.
      '';
      default = {};
      example = { LANG = "en_US.UTF-8"; };
    };

    shell = mkOption {
      type = types.package;
      description = ''
        The shell derivation for use by nix-shell.
      '';
    };
  };

  config = {
    shell.shell = pkgs.mkShell (cfg.extraAttrs // {
      nativeBuildInputs = cfg.packages;
      shellHook = lib.concatStringsSep "\n" cfg.hooks;
    });
  };
}
