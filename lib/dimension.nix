{ lib, ... }:
{
  /*
    Specifies a dimension of the build matrix.

    dimension: name -> attrs -> function -> attrs
    where
      function = keyText -> value -> attrsOf package

    WARNING: Attribute names should not contain periods (".") if nix-build is
             going to be used to traverse the expression.
             See https://github.com/NixOS/nix/issues/3088

    Example:

        dimension "Example" {
          withP = { p = true; }
          withoutP = { p = false; }
        } (key:      # either "withP" or "withoutP"
          { p }:     # either p = true or p = false
          myProject p
        )

    evaluates roughly to

        {
          withP = myProject true;
          withoutP = myProject false;
        }

    Use nested calls for multiple dimensions.

    Example:

        dimension "System" {
          "x86_64-linux" = {};
          # ...
          }: (system: {}:

          dimension "Nixpkgs release" (
            {
              "nixpkgs-19_03".nixpkgs = someSource
            } // optionalAttrs (system != "...") {
              "nixpkgs-unstable".nixpkgs = someOtherSource
            }
            ) (_key: { nixpkgs }:

            myProject system nixpkgs

          )
        )

    evaluates roughly to

        {
          x86_64-linux.nixpkgs-19_03 = myProject "x86_64-linux" someSource;
          x86_64-linux.nixpkgs-unstable = myProject "x86_64-linux" someOtherSource;
          ...
        }

    If you need to make references across attributes, you can do so by binding
    the result. Wherever you write

        dimension "My dimension" {} (key: value: f1 key value)

    You can also write

        let
          myDimension = dimension "My dimension" {} (key: value: f2 key value myDimension)
        in
          myDimension

    This example builds a single test runner to reuse across releases:

        let
          overlay =
            testRunnerPkgs: self: super: {
              # ...
            };
          myProject =
            { nixpkgs,
              pkgs ? import nixpkgs { overlays = [ overlay ]; },
              testRunnerPkgs ? pkgs
            }: pkgs;
        in

        let
          latest = "nixpkgs-19_03";
          releases =
            dimension "Nixpkgs release"
              {
                nixpkgs-18_09.nixpkgs = someSource
                nixpkgs-19_03.nixpkgs = someOtherSource
              }
              (_key: { nixpkgs }:

                myProject {
                  inherit nixpkgs;
                  testRunnerPkgs = releases."${latest}";
                }

              );
        in releases;

   */
  dimension = name: attrs: f:
    lib.mapAttrs
      (
        k: v:
          let
            o = f k v;
          in
            o // { recurseForDerivations = o.recurseForDerivations or true; }
      )
      attrs
    // { meta.dimension.name = name; };

}
