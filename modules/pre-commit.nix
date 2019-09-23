{ config, lib, pkgs, ... }:

let

  inherit (lib)
    attrNames
    filterAttrs
    literalExample
    mapAttrsToList
    mkIf
    mkOption
    types
    ;

  inherit (pkgs) runCommand writeText git;

  cfg = config.pre-commit;

  hookType = types.submodule ({ config, name, ... }: {
    options = {
      enable = mkOption {
        type = types.bool;
        # TODO: actually activate it, s/prepare/enable
        description = ''
          Whether to prepare this pre-commit hook.
        '';
        default = false;
      };
      raw = mkOption {
        type = types.attrsOf types.unspecified;
        description = ''
          Raw fields of a pre-commit hook. This is mostly for internal use but
          exposed in case you need to work around something.

          Default: taken from the other hook options.
        '';
      };
      name = mkOption {
        type = types.str;
        default = name;
        defaultText = literalExample "internal name, same as id";
        description = ''
          The name of the hook - shown during hook execution.
        '';
      };
      entry = mkOption {
        type = types.str;
        description = ''
          The entry point - the executable to run. entry can also contain arguments that will not be overridden such as entry: autopep8 -i.
        '';
      };
      language = mkOption {
        type = types.str;
        description = ''
          The language of the hook - tells pre-commit how to install the hook.
        '';
        default = "system";
      };
      files = mkOption {
        type = types.str;
        description = ''
          The pattern of files to run on.
        '';
        default = "";
      };
      types = mkOption {
        type = types.listOf types.str;
        description = ''
          List of file types to run on. See Filtering files with types (https://pre-commit.com/#plugins).
        '';
        default = ["file"];
      };
      # TODO: exclude and some more
    };
    config = {
      raw =
        {
          inherit (config) name entry language files types;
          id = name;
        };
    };
  });

  processedHooks = mapAttrsToList (id: value: value.raw // { inherit id; } ) (filterAttrs (id: value: value.enable) cfg.hooks);

  precommitConfig = {
    repos = [
      {
        repo = ".pre-commit-hooks/";
        rev = "master";
        hooks = mapAttrsToList (id: _value: { inherit id; }) cfg.hooks;
      }
    ];
  };

  hooksFile =
    writeText "pre-commit-hooks.json" (builtins.toJSON processedHooks);
  configFile =
    writeText "pre-commit-config.json" (builtins.toJSON precommitConfig);

  hooks =
    runCommand "pre-commit-hooks-dir" { buildInputs = [ git ]; } ''
      HOME=$PWD
      mkdir -p $out
      ln -s ${hooksFile} $out/.pre-commit-hooks.yaml
      cd $out
      git config --global user.email "you@example.com"
      git config --global user.name "Your Name"
      git init
      git add .
      git commit -m "init"
    '';

  run =
    runCommand "pre-commit-run" { buildInputs = [ git ]; } ''
      set +e
      HOME=$PWD
      cp --no-preserve=mode -R ${src} src
      unlink src/.pre-commit-hooks || true
      ln -fs ${hooks} src/.pre-commit-hooks
      cd src
      rm -rf src/.git
      git init
      git add .
      git config --global user.email "you@example.com"
      git config --global user.name "Your Name"
      git commit -m "init"
      echo "Running: $ pre-commit run --all-files"
      ${cfg.package}/bin/pre-commit run --all-files
      exitcode=$?
      git --no-pager diff --color
      touch $out
      [ $? -eq 0 ] && exit $exitcode
    '';

  srcStr = toString ( config.root.origSrc or config.root );

  # TODO: allow gitignore.nix
  src = config.root;

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
      '';
    };

    package = mkOption {
      type = types.package;
      description = ''
        The pre-commit package to use.
      '';
      default = pkgs.pre-commit;
      defaultText = literalExample ''
        pkgs.pre-commit
      '';
    };

    hooks = mkOption {
      type = types.attrsOf hookType;
      description = ''
        The hook definitions.
      '';
      default = {};
    };
  };

  config = mkIf cfg.enable {

    shell.packages = [ cfg.package ];

    activation.hooks = mkIf cfg.enableAutoInstall [
      ''
        export PATH=$PATH:${cfg.package}/bin
        if ! type -t git >/dev/null; then
          # This happens in pure shells, including lorri
          echo 1>&2 "WARNING: nix-pre-commit-hooks: git command not found; skipping installation."
        else
          (
            # We use srcStr to protect against installing pre-commit hooks
            # in the wrong places such as for example ./. when invoking
            #   nix-shell ../../other-project/shell.nix
            cd ${lib.escapeShellArg srcStr} && {
              # Avoid filesystem churn. We may be watched!
              # This prevents lorri from looping after every interactive shell command.
              if readlink .pre-commit-hooks >/dev/null \
                && [[ $(readlink .pre-commit-hooks) == ${hooks} ]]; then
                echo 1>&2 "nix-pre-commit-hooks: hooks up to date"
              else
                echo 1>&2 "nix-pre-commit-hooks: updating" ${lib.escapeShellArg srcStr}

                [ -L .pre-commit-hooks ] && unlink .pre-commit-hooks
                ln -s ${hooks} .pre-commit-hooks

                # This can't be a symlink because its path is not constant,
                # thus can not be committed and is invisible to pre-commit.
                unlink .pre-commit-config.yaml
                { echo '# DO NOT MODIFY';
                  echo '# This file was generated by project.nix';
                  ${pkgs.jq}/bin/jq . <${configFile}
                } >.pre-commit-config.yaml

                pre-commit install
                # this is needed as the hook repo configuration is cached
                pre-commit clean
              fi
            }
          )
        fi
      ''
    ];

  };
}