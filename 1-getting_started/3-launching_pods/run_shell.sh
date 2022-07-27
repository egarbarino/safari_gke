#!/bin/sh

# Using -i -t (-it) to enable input and a terminal 
kubectl run my-pod --image=alpine --restart=Never -it --rm sh

# Experiments
# - Launch various background processes such as 'sleep 30 &'
# - Try hostname
# - Fetch an Internet resource using 'wget'
# - Check IP address using 'ifconfig eth0' and 
#   show 'kubectl get pod/my-pod -o yaml' outside

