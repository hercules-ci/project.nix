{ config, lib, pkgs, ... }:

let

  inherit (lib)
    mkIf
    mkOption
    types
    ;

  cfg = config.pre-commit;

in
{
  options.pre-commit = {

    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable pre-commit integration.

        https://pre-commit.com/
      '';
    };

    enableAutoInstall = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to auto install pre-commit when invoking nix-shell in the
        project root.

        Unused if not pre-commit.enabled.
      '';
    };

  };

  config = mkIf cfg.enable {

    shell.packages = [ cfg.package ];

    activation.hooks = mkIf cfg.enableAutoInstall [
      config.pre-commit.installationScript
    ];

  };
}
