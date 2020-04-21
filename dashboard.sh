#!/bin/bash

namespace=${1:-default}
file=$(mktemp)
echo -e "Pods in '$namespace' namespace:\n" >>"$file"

kubectl proxy -p 58154 &>/dev/null &
sleep 0.3

unbuffer curl "http://localhost:58154/api/v1/namespaces/$namespace/pods?watch=1" |
  while read -r line; do
    name=$(jq -r .object.metadata.name <<<"$line")
    case $(jq -r .type <<<"$line") in
      ADDED) echo "$name" >>"$file" ;;
      DELETED) sed -i "/^$name$/d" "$file";;
    esac
  done &

cleanup() {
  pkill -fn "curl http://localhost:58154"
  pkill -fn "kubectl proxy"
}
trap cleanup SIGINT

watch -t -n 0.1 cat "$file"
