{ pkgs, sources, ... }:
{
  checks.example = pkgs.hello;
  checks.viaSource = (import sources.nixpkgs { inherit (pkgs) system config; }).figlet;

  checks.override = import sources.foo { inherit pkgs; };
  pinning.niv.sources.foo = ../vendored-foo;
}
