{ writeShellApplication }:
# writeShellApplication runs shellcheck on the script at build time.
writeShellApplication {
  name = "kevdev-refresh";
  text = builtins.readFile ./kevdev-refresh.sh;
}
