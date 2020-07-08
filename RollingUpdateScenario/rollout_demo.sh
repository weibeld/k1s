#!/bin/sh

NAME=ckad-demo
IMAGE_BASE=mjbright/ckad-demo
DEPLOY=deploy/$NAME
SVC=svc/$NAME

press() {
    #BANNER "$*"
    [ $PROMPTS -eq 0 ] && return

    echo "Press <return>"
    read _DUMMY
    [ "$_DUMMY" = "q" ] && exit 0
    [ "$_DUMMY" = "Q" ] && exit 0
}

RUN() {
    CMD=$@
    echo; echo "-- CMD: $CMD"
    eval $CMD
}

PAUSE_RUN() {
    CMD=$@
    echo; echo "-- CMD: $CMD"
    read _DUMMY
    [ "$_DUMMY" = "q" ] && exit 0
    [ "$_DUMMY" = "Q" ] && exit 0

    eval $CMD
}

CLEANUP() {
   kubectl delete $DEPLOY
   kubectl delete $SVC
}

CLEANUP 2>/dev/null

PAUSE_RUN kubectl create deploy $NAME --image ${IMAGE_BASE}:1
PAUSE_RUN kubectl expose $DEPLOY  --port 80
kubectl get all | grep $NAME

PAUSE_RUN kubectl scale $DEPLOY --replicas=10
PAUSE_RUN kubectl set image $DEPLOY ${NAME}=${IMAGE_BASE}:2 --record
RUN kubectl rollout status ${DEPLOY}
PAUSE_RUN kubectl rollout history ${DEPLOY}

PAUSE_RUN kubectl set image ${DEPLOY} ${NAME}=${IMAGE_BASE}:3 --record
RUN kubectl rollout status ${DEPLOY}
PAUSE_RUN kubectl rollout history ${DEPLOY}
PAUSE_RUN kubectl rollout undo ${DEPLOY}

exit 0

