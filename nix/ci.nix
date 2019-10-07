{ projectNix ? import ../default.nix {}
, project ? projectNix.evalProject { modules = [ ./project.nix ]; }
}:

{
  pre-commit = project.config.pre-commit.run;
}
