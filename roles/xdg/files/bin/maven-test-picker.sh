#!/usr/bin/env bash
set -Eeuo pipefail

# Interactively select individual JUnit test methods and run them with Maven.
# Any arguments passed to this script are forwarded to Maven, for example:
#   ./maven-test-picker.sh -pl my-module -am

for command_name in mvn fzf python3 find; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command not found: $command_name" >&2
    exit 127
  fi
done

mapfile -d '' test_files < <(
  find . -type f -path '*/src/test/java/*.java' -print0
)

if ((${#test_files[@]} == 0)); then
  echo "No Java tests found below */src/test/java/." >&2
  exit 1
fi

# Emit Maven selectors in the form fully.qualified.ClassName#methodName.
# Recognizes common JUnit 4/JUnit 5 test annotations.
mapfile -t selected < <(
  python3 - "${test_files[@]}" <<'PYTHON' |
import pathlib
import re
import sys

test_method = re.compile(
    r"@(?:[\w.]+\.)?"
    r"(?:Test|ParameterizedTest|RepeatedTest|TestFactory|TestTemplate)\b"
    r"(?:\s*\([^;{}]*\))?"
    r"(?:\s*@[\w.]+(?:\s*\([^;{}]*\))?)*\s*"
    r"(?:(?:public|protected|private|static|final|synchronized|abstract|native|strictfp)\s+)*"
    r"(?:<[^;{}]+>\s*)?"
    r"[\w.$<>\[\],?]+\s+([A-Za-z_$][\w$]*)\s*\(",
    re.MULTILINE,
)

for filename in sys.argv[1:]:
    path = pathlib.Path(filename)
    source = path.read_text(encoding="utf-8")
    package_match = re.search(r"\bpackage\s+([\w.]+)\s*;", source)
    class_name = path.stem
    fqcn = (
        f"{package_match.group(1)}.{class_name}"
        if package_match
        else class_name
    )
    for method in test_method.finditer(source):
        print(f"{fqcn}#{method.group(1)}")
PYTHON
    sort -u |
    fzf --multi \
        --prompt='Tests > ' \
        --header='TAB: mark/unmark  ENTER: run  ESC: cancel' \
        --bind='space:toggle+down' \
        --marker='✓'
)

if ((${#selected[@]} == 0)); then
  echo "No tests selected."
  exit 0
fi

# Surefire accepts comma-separated Class#method selectors. Quoting keeps # and
# Maven property syntax away from shell interpretation.
selectors=$(IFS=,; printf '%s' "${selected[*]}")

printf 'Running %d selected test method(s):\n' "${#selected[@]}"
printf '  %s\n' "${selected[@]}"

mvn \
  -Dtest="$selectors" \
  -Dsurefire.failIfNoSpecifiedTests=false \
  "$@" \
  test

