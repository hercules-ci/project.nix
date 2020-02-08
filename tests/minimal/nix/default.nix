{ ... }: 
let inherit (import (import ./source-project.nix)) evalProject;
in (evalProject { modules = [ ./project.nix ]; }).config
