{ config, defaultSources, lib, pkgs, ... }:

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

    source = mkOption {
      type = types.path;
      default = defaultSources.nix-pre-commit-hooks;
      defaultText = lib.literalExample "defaultSources.nix-pre-commit-hooks";
    };

    settings = mkOption {
      type = types.submoduleWith {
        modules = [ (cfg.source + "/modules/all-modules.nix") ];
        specialArgs = { inherit pkgs; };
      };
    };

  };

  config = mkIf cfg.enable {

    shell.packages = [ cfg.settings.package ];

    activation.hooks = [
      config.pre-commit.settings.installationScript
    ];

    checks.pre-commit = cfg.settings.run;

    pre-commit.settings = {
      rootSrc = config.rootSource;
      package = lib.mkDefault pkgs.pre-commit;
    };
  };
}
