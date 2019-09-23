{ config, lib, ... }:

let
  inherit (lib) mkOption mkOptionType literalExample types;

  pkgsType = mkOptionType {
    name = "nixpkgs";
    description = "An evaluation of Nixpkgs; the top level attribute set of packages";
    check = builtins.isAttrs;
  };

in
{
  options.nixpkgs.pkgs = mkOption {
    type = pkgsType;
    description = ''
      This option specifies the pkgs argument to all project.nix modules.

      Note that the lib argument is provided by project.nix (pinned by default) or its caller.
    '';

    default =
      import (config.root + "/nix/default.nix") {};
    defaultText = literalExample
      ''import (config.root + "/nix/default.nix") {}'';
  };

  config._module.args = {
    pkgs = config.nixpkgs.pkgs;
  };
}
