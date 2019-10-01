{ lib ? import ((import ./nix/sources.nix).nixpkgs + "/lib")
, ...
}:

let

  evalProject =
    { modules ? [] }: lib.evalModules {
      check = true;
      modules = builtinModules ++ modules;
      specialArgs = { inherit scanProjectModules; };
    };

  scanProjectModules = scan "nix/project-module.nix";

  # Like a PATH search, where filePath is like bin/somecommand
  #
  #     scan : string -> sources -> listOf module
  #
  # Arguments
  #
  #     filePath : string       File to look for in the sources
  #
  #     sources : attrsOf path  Sources that may contain a file named ${filePath}
  #            or path          or a path that has such a Nix expression
  scan = filePath:
    let
      withAsserts =
        assert builtins.typeOf filePath == "string";
        x: x;

      importify =
        f: x:
          if lib.types.path.check x
          then builtins.addErrorContext
            "while scanning for modules in ${toString x}"
            (f (import x))
          else builtins.addErrorContext
            "while scanning for modules"
            (f x);

      scanAttrs = attrs:
        lib.concatLists (
          lib.mapAttrsToList (
            key: value:
              builtins.addErrorContext
                "while scanning attribute ${key}"
                (scanIfDirlike value)
          )
            attrs
        );

      scanIfDirlike = value:
        if lib.types.path.check value
        then let
          potential = value + "/${filePath}";
        in
          if builtins.pathExists potential then [ potential ] else []
        else [];
    in
      withAsserts (importify scanAttrs);

  builtinModules = [
    ./modules/root.nix
    ./modules/nixpkgs.nix
    ./modules/shell.nix
    ./modules/niv.nix
    ./modules/pre-commit.nix
    ./modules/activation.nix
    ./modules/formatters/nixpkgs-fmt.nix
  ];

in
{
  inherit evalProject;

}
