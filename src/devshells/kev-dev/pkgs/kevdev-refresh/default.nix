{ writeShellScriptBin }:
let
  scriptText = builtins.readFile ./kevdev-refresh.sh;
in
writeShellScriptBin "kevdev-refresh" scriptText
