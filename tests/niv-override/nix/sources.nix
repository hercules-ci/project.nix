# We cheat a bit here to pretend that project.nix is inside niv's sources.nix.
(import ./niv-sources.nix) // {
  "project.nix" = { outPath = "${../../..}"; };

  "foo" = builtins.throw "The foo sources is broken and should not even be evaluated because of an override.";

  # The result should also have the project.nix override. Implement if needed.
  __functor = a: b: { "project.nix" = builtins.throw "niv's __functor is not yet supported by the test fixture."; };
}
