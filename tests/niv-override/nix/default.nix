args@{ sources ? import ./sources.nix
, extraModules ? []
, ...
}:
(
  (import sources."project.nix").evalNivProject (
    {
      modules = [ ./project.nix ] ++ extraModules;
      inherit sources;
    }
  )
).config
