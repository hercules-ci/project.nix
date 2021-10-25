{ sources ? import ./sources.nix
, system ? builtins.currentSystem
}:

import sources.nixpkgs {
  overlays = [ ];
  config = { };
  inherit system;
}
