{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "jj-github-send" ''
      set -euo pipefail
      if [ -n "''${1:-}" ]; then
        REV="$1"
      else
        REV="$(jj log -r 'heads((trunk()..@) ~ empty())' -T 'commit_id' --no-graph -n 1)"
      fi
      jj git push -c "$REV"
    '')
  ];
}
