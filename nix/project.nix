{
  # imports = scan "nix/project-module.nix" ./sources.nix;

  imports = [
    ((import ./sources.nix).nix-pre-commit-hooks + "/nix/project-module.nix")
  ];

  root = ../.;
  pinning.niv.enable = true;
  pre-commit.enable = true;
  formatters.nixpkgs-fmt.enable = true;
}
