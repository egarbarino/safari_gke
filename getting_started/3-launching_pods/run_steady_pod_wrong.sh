#!/bin/sh

# This command won't complete. The pod will keep crashing
# and will need to be killed with `kubectl delete pod/my-pod`
kubectl run my-pod --image=alpine sh 

