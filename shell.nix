{ projectNix ? import ./default.nix
, project ? projectNix.evalNivProject { modules = [ ./nix/project.nix ]; sources = import ./nix/sources.nix; }
}:
project.config.shell.shell
