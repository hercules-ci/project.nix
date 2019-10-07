/*

  This is a _project.nix configuration_
  for project.nix _itself_.

 */
{ config, lib, pkgs, ... }: {

  imports = [
    ((import ./sources.nix).nix-pre-commit-hooks + "/nix/project-module.nix")
  ];

  root = ../.;
  pinning.niv.enable = true;
  pre-commit.enable = true;
  pre-commit.tools.nixpkgs-fmt = lib.mkForce pkgs.nixpkgs-fmt;
  pre-commit.hooks.nixpkgs-fmt.enable = true;

  # TODO: upstream the command line change, remove this
  pre-commit.hooks.nixpkgs-fmt.entry = lib.mkForce "${config.pre-commit.tools.nixpkgs-fmt}/bin/nixpkgs-fmt";
}
