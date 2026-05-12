#!/usr/bin/env bash
set -euo pipefail

status=$1
input=$2
output=$3

icon=$( [ "$status" = "success" ] && echo "✅" || echo "⚠️" )

cat <<EOF > "$output"
### ${icon} Slither Analysis

<details>
<summary>Click to expand</summary>

\`\`\`
$(cat "$input")
\`\`\`

</details>
EOF
