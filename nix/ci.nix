{ projectNix ? import ../default.nix
, project ? projectNix.evalNivProject { modules = [ ./project.nix ]; sources = import ./sources.nix; }
}:
project.config.checks
