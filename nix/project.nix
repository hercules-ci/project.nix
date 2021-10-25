/*

  This is a _project.nix configuration_
  for project.nix _itself_.

*/
{ config, lib, pkgs, defaultSources, ... }: {
  root = ../.;
  pre-commit.enable = true;
  pre-commit.settings.tools.nixpkgs-fmt = lib.mkForce pkgs.nixpkgs-fmt;
  pre-commit.settings.hooks.nixpkgs-fmt.enable = true;
  pre-commit.settings.excludes = [ "tests/.*" ];

  # TODO assert presence of the example check inside
  checks.tests.minimal = import ../tests/minimal { };
  checks.tests.minimal-niv = import ../tests/minimal-niv { };
  checks.tests.niv-override = import ../tests/niv-override { };
}
