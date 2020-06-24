#!/bin/bash

set -o pipefail

namespace=${1:-default}
resource_type=${2:-pods}

# Check resource type and identify API path
printf Loading && while true; do printf . && sleep 0.1; done &
if ! path=$(kubectl get "$resource_type" -n "$namespace" -v 6 2>&1 >/dev/null | grep GET | tail -n 1 | sed -n 's#.*https://[^/]*\([/a-z0-9-]*\).*#\1#p'); then
  kill -9 "$!" && echo -e "\nInvalid resource type: $resource_type" && exit 1
fi
kill -9 "$!" && wait "$!" 2>/dev/null

# Start kubectl proxy
exec 4< <(kubectl proxy -p 0)
port=$(head -n 1 <&4 | sed 's/.*:\([0-9]\{4,5\}\)\b.*/\1/')

file=$(mktemp)
cat <<EOF >"$file"
 ____ ____ ____
||k |||1 |||s ||  Kubernetes Dashboard
||__|||__|||__||  Namespace: $namespace
|/__\|/__\|/__\|  Resources: ${path##*/}

EOF

colorize() {
    case "$1" in Running) color=32;; Pending) color=33;; *) color=31;; esac
    printf "\033[${color}m$1\033[0m"
}

curl -N -s "http://localhost:$port$path?watch=true" |
  while read -r line; do
    name=$(jq -r '.object.metadata.name' <<<"$line")
    if [[ "${path##*/}" = pods ]]; then
      pod_info=$(jq -r '.object.status.phase' <<<"$line")
      is_ready=$(jq -r 'if .object.status | has("conditions") then .object.status.conditions[] | select(.type=="Ready").status else "False" end' <<<"$line")
      [[ "$pod_info" = Running && "$is_ready" != True ]] && pod_info=Pending
      pod_info=$(colorize "$pod_info")
    fi
    case $(jq -r .type <<<"$line") in
      ADDED) echo "$name $pod_info" >>"$file" ;;
      MODIFIED) sed -i "s/^$name .*$/$name $pod_info/" "$file" ;;
      DELETED) sed -i "/^$name .*$/d" "$file";;
    esac
  done &

watch -ctn 0.1 cat "$file"
