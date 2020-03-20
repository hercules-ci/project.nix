/*

  This is a _project.nix configuration_
  for project.nix _itself_.

 */
{ config, lib, pkgs, defaultSources, ... }: {

  imports = [
    (defaultSources.nix-pre-commit-hooks + "/nix/project-module.nix")
  ];

  root = ../.;
  pre-commit.enable = true;
  pre-commit.tools.nixpkgs-fmt = lib.mkForce pkgs.nixpkgs-fmt;
  pre-commit.hooks.nixpkgs-fmt.enable = true;
  pre-commit.excludes = [ "tests/.*" ];

  # TODO assert presence of the example check inside
  checks.tests.minimal = import ../tests/minimal {};
  checks.tests.minimal-niv = import ../tests/minimal-niv {};
  checks.tests.niv-override = import ../tests/niv-override {};
}
