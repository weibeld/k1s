#!/bin/sh

NAME=ckad-demo

GET_SVC_IP() {
    IP=$(kubectl get svc ckad-demo --no-headers | awk '{ print $3; }')
}

GET_SVC_IP

while true; do
    if [ -z "$IP" ]; then
        GET_SVC_IP
    else
        curl ${IP}:80/c;
        [ $? -ne 0 ] && GET_SVC_IP
    fi
    sleep 1;
done

