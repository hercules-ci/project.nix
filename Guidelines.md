
### Packaging

1. Prefer pre-packaged derivations from Nixpkgs
2. When packaging a tool using its own nix expressions, try to pass `{ inherit pkgs; }` to keep evaluation performance acceptable and closure size reasonable.
3. Use upstream pins as a last resort + make an issue to resolve it

Do not add dependency source to this repository. Wrapper scripts for integration are ok, but whole programs are better maintained in a separate repo.
