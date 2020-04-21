#!/bin/bash

namespace=${1:-default}
file=$(mktemp)
echo -e "Pods in '$namespace' namespace:\n" >>"$file"

kubectl proxy -p 58154 &>/dev/null &
printf Loading && for i in 1 2 3; do printf . && sleep 0.3; done

unbuffer curl "http://localhost:58154/api/v1/namespaces/$namespace/pods?watch" |
  while read -r line; do
    name=$(jq -r .object.metadata.name <<<"$line")
    status=$(jq -r .object.status.phase <<<"$line")
    case "$status" in Running) color=32;; Pending) color=33;; *) color=31;; esac
    status=$(printf "\033[${color}m$status\033[0m")
    case $(jq -r .type <<<"$line") in
      ADDED) echo "$name $status" >>"$file" ;;
      MODIFIED) sed -i "s/^$name .*$/$name $status/" "$file" ;;
      DELETED) sed -i "/^$name .*$/d" "$file";;
    esac
  done &

cleanup() {
  pkill -fn "curl http://localhost:58154"
  pkill -fn "kubectl proxy"
}
trap cleanup SIGINT

watch -ctn 0.1 cat "$file"
