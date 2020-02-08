{ pkgs, ... }:
{
  nixpkgs.source = import ./source-nixpkgs.nix;
  checks.example = pkgs.hello;
}