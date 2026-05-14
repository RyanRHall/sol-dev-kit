#!/usr/bin/env bash
set -euo pipefail

status=$1
header=$2
input=$3
output=$4

icon=$( [ "$status" = "success" ] && echo "✅" || echo "⚠️" )

{
  echo "### ${icon} ${header}"
  echo ""
  echo "<details>"
  echo "<summary>Click to expand</summary>"
  echo ""
  [[ "$input" != *.md ]] && echo '```'
  cat "$input"
  [[ "$input" != *.md ]] && echo '```'
  echo ""
  echo "</details>"
} > "$output"
