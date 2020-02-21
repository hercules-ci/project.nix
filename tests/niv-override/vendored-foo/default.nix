{ pkgs }:

pkgs.runCommand "vendored-foo" {} ''
  echo foo, but better >$out
''