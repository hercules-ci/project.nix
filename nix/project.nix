/*

  This is a _project.nix configuration_
  for project.nix _itself_.

 */
{ config, lib, pkgs, sources, ... }: {

  imports = [
    (sources.nix-pre-commit-hooks + "/nix/project-module.nix")
  ];

  root = ../.;
  pre-commit.enable = true;
  pre-commit.tools.nixpkgs-fmt = lib.mkForce pkgs.nixpkgs-fmt;
  pre-commit.hooks.nixpkgs-fmt.enable = true;

}
