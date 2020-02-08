# We cheat a bit here to pretend that project.nix is inside niv's sources.nix.
(import ./niv-sources.nix) // {
  "project.nix" = { outPath = "${../../..}"; };

  # The result should also have the project.nix override. Implement if needed.
  __functor = builtins.throw "niv's __functor is not yet supported by the test fixture.";
}
