{ scanProjectModules, ... }:
{
  imports = scanProjectModules ./sources.nix;

  root = ../.;
  pinning.niv.enable = true;
  pre-commit.enable = true;
  formatters.nixpkgs-fmt.enable = true;
}
