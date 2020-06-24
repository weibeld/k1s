#!/bin/bash

namespace=${1:-default}
resource=pods
file=$(mktemp)

cat <<EOF >"$file"
 ____ ____ ____
||k |||1 |||s ||  Kubernetes dashboard
||__|||__|||__||  Namespace: $namespace
|/__\|/__\|/__\|  Resource: $resource

EOF

exec 3< <(kubectl proxy -p 0)
port=$(head -n 1 <&3 | sed 's/.*:\([0-9]\{4,5\}\)\b.*/\1/')

printf Loading && for _ in 1 2 3; do printf . && sleep 0.3; done

curl -N -s "http://localhost:$port/api/v1/namespaces/$namespace/pods?watch=true" |
  while read -r line; do
    name=$(jq -r '.object.metadata.name' <<<"$line")
    phase=$(jq -r '.object.status.phase' <<<"$line")
    is_ready=$(jq -r 'if .object.status | has("conditions") then .object.status.conditions[] | select(.type=="Ready").status else "False" end' <<<"$line")
    [[ "$phase" = Running && "$is_ready" != True ]] && phase=Pending
    case "$phase" in Running) color=32;; Pending) color=33;; *) color=31;; esac
    phase=$(printf "\033[${color}m$phase\033[0m")
    case $(jq -r .type <<<"$line") in
      ADDED) echo "$name $phase" >>"$file" ;;
      MODIFIED) sed -i "s/^$name .*$/$name $phase/" "$file" ;;
      DELETED) sed -i "/^$name .*$/d" "$file";;
    esac
  done &

watch -ctn 0.1 cat "$file"
