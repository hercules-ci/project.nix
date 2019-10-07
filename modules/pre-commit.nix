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

  };

  config = mkIf cfg.enable {

    shell.packages = [ cfg.package ];

    activation.hooks = [
      config.pre-commit.installationScript
    ];

  };
}
