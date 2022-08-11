#!/bin/sh

# This will leave Pod running in the background
kubectl run my-pod --image=alpine sleep infinity 

# Wait for pod to start
sleep 5 

# Run `date` on container
kubectl exec my-pod -- date

# Run `ls -l` on container
kubectl exec my-pod -- ls -l

# Pipe data
cat /etc/resolv.conf | kubectl exec -i my-pod -- wc 

# Open shell
kubectl exec my-pod -ti -- sh

# Experiments
#
# - Exit and enter shell again 
# - Delete Pod




