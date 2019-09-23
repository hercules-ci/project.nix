{ projectNix ?
    import ./default.nix {}
, project ?
    projectNix.evalProject { modules = [ ./nix/project.nix ]; }
}:

project.config.shell.shell
