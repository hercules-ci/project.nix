{ lib ?
    import ((import ./nix/sources.nix).nixpkgs + "/lib")
, ...
}:

let

  evalProject =
    { modules ? [] }: lib.evalModules {
      check = true;
      modules = builtinModules ++ modules;
    };

  builtinModules = [
    ./modules/root.nix
    ./modules/nixpkgs.nix
    ./modules/shell.nix
    ./modules/niv.nix
    ./modules/pre-commit.nix
  ];

in
{
  inherit evalProject;

}