#!/bin/bash

set -o pipefail
namespace=${1:-default}
resource_type=${2:-pods}

printf Loading && while true; do printf . && sleep 0.1; done &
if ! path=$(kubectl get "$resource_type" -n "$namespace" -v 6 2>&1 >/dev/null | grep GET | tail -n 1 | sed -n 's#.*https://[^/]*\([a-z0-9/.-]*\).*#\1#p'); then
  kill -9 "$!" && echo -e "\nInvalid resource type: $resource_type" && exit 1
fi
kill -9 "$!" && wait "$!" 2>/dev/null
resource_type=${path##*/}

exec 3< <(kubectl proxy -p 0)
port=$(head -n 1 <&3 | sed 's/.*:\([0-9]\{4,5\}\)\b.*/\1/')

c() { echo -e "\033[$1m"; }
cc() { echo -e "\033[$1;1m"; }

file=$(mktemp)
cat <<EOF >"$file"
$(cc 36) ____ ____ ____
||$(cc 33)k$(cc 36) |||$(cc 33)1$(cc 36) |||$(cc 33)s$(cc 36) ||  $(cc 0)Kubernetes Dashboard$(cc 36)
||__|||__|||__||  $(cc 0)Namespace: $namespace$(cc 36)
|/__\|/__\|/__\|  $(cc 0)Resources: $resource_type$(cc 36)
$(c 0)
EOF

curl -N -s "http://localhost:$port$path?watch=true" |
  while read -r line; do
    name=$(jq -r '.object.metadata.name' <<<"$line")
    case "$resource_type" in
    pods)
      phase=$(jq -r '.object.status.phase' <<<"$line")
      is_ready=$(jq -r 'if .object.status | has("conditions") then .object.status.conditions[] | if select(.type=="Ready").status=="True" then "true" else "" end else "" end' <<<"$line")
      is_scheduled=$(jq -r 'if .object.status | has("conditions") then .object.status.conditions[] | if select(.type=="PodScheduled").status=="True" then "true" else "" end else "" end' <<<"$line")
      [[ "$is_scheduled" && ! "$is_ready" ]] && info=NonReady || info=$phase
      [[ "$info" = Running ]] && info=$(c 32)$info$(c 0) || info=$(c 33)$info$(c 0) ;;
    deployments|replicasets|statefulsets)
      spec=$(jq -r '.object.spec.replicas' <<<"$line")
      stat=$(jq -r '.object.status.readyReplicas // 0' <<<"$line")
      [[ "$stat" = "$spec" ]] && info="$(c 32)($stat/$spec)$(c 0)" || info="$(c 33)($stat/$spec)$(c 0)" ;;
    esac
    case $(jq -r .type <<<"$line") in
      ADDED) echo "$name $info" >>"$file" ;;
      MODIFIED) sed -i "s/^$name .*$/$name ${info//\//\\/}/" "$file" ;;
      DELETED) sed -i "/^$name .*$/d" "$file";;
    esac
  done &

watch -ctn 0.1 cat "$file"
