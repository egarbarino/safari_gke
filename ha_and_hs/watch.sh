#!/bin/sh
#
# Usage: ./watch.sh SERVICE_NAME
#
PUBLIC_IP=$(kubectl get service/$1 -o=jsonpath={.status.loadBalancer.ingress[*].ip})
while true; do curl -s -i --max-time 0.5 http://$PUBLIC_IP | grep Server; sleep 1 ; done