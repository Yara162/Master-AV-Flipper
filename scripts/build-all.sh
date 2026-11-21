#!/usr/bin/env bash
# Build every Flipper app (each folder holding an application.fam) under the given folders with ufbt.
# Usage: scripts/build-all.sh OUT_DIR FOLDER...
# Leaves the .fap files in OUT_DIR and a summary in OUT_DIR/build-summary.md.
# Exits 1 if any app fails. Needs ufbt (pip install ufbt) with an SDK already chosen by `ufbt update`.
set -uo pipefail

out=${1:?usage: build-all.sh OUT_DIR FOLDER...}
shift
mkdir -p "$out"
out=$(cd "$out" && pwd)
summary="$out/build-summary.md"
sdk=$(ufbt status 2>&1 | awk '/] Version /{print $NF; exit}')
{
  echo "| App | Folder | Result |"
  echo "|---|---|---|"
} > "$summary"

failed=0
built=0
while IFS= read -r fam; do
  dir=$(dirname "$fam")
  appid=$(sed -n 's/.*appid *= *"\([^"]*\)".*/\1/p' "$fam" | head -1)
  log="$out/${appid:-unknown}.log"
  if (cd "$dir" && rm -rf dist && ufbt >"$log" 2>&1) && ls "$dir"/dist/*.fap >/dev/null 2>&1; then
    cp "$dir"/dist/*.fap "$out/"
    echo "| \`$appid\` | \`$dir\` | built |" >> "$summary"
    echo "built  $appid  ($dir)"
    built=$((built + 1))
  else
    echo "| \`$appid\` | \`$dir\` | **failed** (see $appid.log) |" >> "$summary"
    echo "FAILED $appid  ($dir)  -- last lines of $log:"
    tail -15 "$log" | sed 's/^/    /'
    failed=$((failed + 1))
  fi
done < <(find "$@" -name application.fam -not -path '*/.ufbt/*' -not -path '*/dist/*' | sort)

echo "" >> "$summary"
echo "SDK: ${sdk:-unknown}. Built $built, failed $failed." >> "$summary"
echo "SDK ${sdk:-unknown}: built $built, failed $failed"
[ "$failed" -eq 0 ]
