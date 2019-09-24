{ config, lib, ... }:

let

  inherit (lib)
    concatStringsSep
    hasPrefix
    literalExample
    mkIf
    mkOption
    mkOptionType
    mkOrder
    types
    ;

  cfg = config.activation;

  isOutsideStore = p: !(hasPrefix builtins.storeDir (toString p));

in
{
  options = {

    activation.hooks = mkOption {
      type = types.listOf types.str;
      description = ''
        bash snippets to run on activation.

        This is quite distinct from a shell hook:
         - the working directory is always the project root.
         - variables are not propagated to the shell.
         - activation hooks may be run separately or before most shell.hooks.
      '';
      default = [];
    };

    activation.enableShellHook = mkOption {
      type = types.bool;
      description = ''
        Whether to run the activation hooks whenever the project shell is opened.
      '';
      default = true;
    };

  };

  config =
    mkIf cfg.enableShellHook {

      shell.extraAttrs.activationHook =
        concatStringsSep "\n" cfg.hooks;

      shell.hooks = mkIf (isOutsideStore config.root) (
        mkOrder 300 [
          ''
            (
              echo 1>&2 project.nix: activating in ${lib.escapeShellArg config.root}
              cd ${lib.escapeShellArg config.root}
              runHook activationHook
            )
          ''
        ]
      );
    };

}
