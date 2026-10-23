#!/bin/sh

message_file="$1"
subject=$(head -n 1 "$message_file")

conventional_pattern='^(feat|fix|docs|refactor|test|chore|style|perf|build|ci|revert)(\([a-z0-9-]+\))?!?: .+'
exempt_pattern='^(Merge |Revert "|fixup! |squash! )'

if printf '%s\n' "$subject" | grep -Eq "$conventional_pattern|$exempt_pattern"; then
  exit 0
fi

cat >&2 <<EOF
Commit message does not follow conventional commits:

  $subject

Expected: <type>(<optional scope>): <description>
Types: feat, fix, docs, refactor, test, chore, style, perf, build, ci, revert
Example: feat(consensus): add avalanche sampling
EOF
exit 1
