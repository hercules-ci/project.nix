{ ... }: 
let inherit (import (import ./source-project.nix)) evalProject;
in (evalProject {
    modules = [ ./project.nix ];
    nixpkgs = import ./source-nixpkgs.nix;
  }).config
