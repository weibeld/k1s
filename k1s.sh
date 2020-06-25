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
resource_type=${path##*/}

# Start kubectl proxy
exec 4< <(kubectl proxy -p 0)
port=$(head -n 1 <&4 | sed 's/.*:\([0-9]\{4,5\}\)\b.*/\1/')

file=$(mktemp)
cat <<EOF >"$file"
 ____ ____ ____
||k |||1 |||s ||  Kubernetes Dashboard
||__|||__|||__||  Namespace: $namespace
|/__\|/__\|/__\|  Resources: $resource_type

EOF

color() {
  case "$1" in 0) c=32;; *) c=33;; esac
  echo -e "\033[${c}m$2\033[0m"
}

curl -N -s "http://localhost:$port$path?watch=true" |
  while read -r line; do
    name=$(jq -r '.object.metadata.name' <<<"$line")
    case "$resource_type" in
    pods)
      info=$(jq -r '.object.status.phase' <<<"$line")
      is_ready=$(jq -r 'if .object.status | has("conditions") then .object.status.conditions[] | select(.type=="Ready").status else "False" end' <<<"$line")
      [[ "$info" = Running && "$is_ready" != True ]] && info=Pending
      [[ "$info" = Running ]] && info=$(color 0 "$info") || info=$(color 1 "$info") ;;
    deployments|replicasets|statefulsets)
      spec=$(jq -r '.object.spec.replicas' <<<"$line")
      stat=$(jq -r '.object.status.readyReplicas // 0' <<<"$line")
      info="($stat/$spec)"
      [[ "$stat" = "$spec" ]] && info=$(color 0 "$info") || info=$(color 1 "$info") ;;
    esac
    case $(jq -r .type <<<"$line") in
      ADDED) echo "$name $info" >>"$file" ;;
      MODIFIED) sed -i "s/^$name .*$/$name ${info//\//\\/}/" "$file" ;;
      DELETED) sed -i "/^$name .*$/d" "$file";;
    esac
  done &

watch -ctn 0.1 cat "$file"
