{ pkgs, sources, ... }:
{
  checks.example = pkgs.hello;
  checks.viaSource = (import sources.nixpkgs { inherit (pkgs) system config; }).figlet;
}
