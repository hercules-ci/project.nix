# Approximation of a fetcher. Don't do this in normal projects.
# This indirection removes all niv-ness. Imagine this could be any other
# expression returning a nixpkgs source.
{ inherit ((import ../../../nix/sources.nix).nixpkgs) outPath; }
