#!/bin/sh

# Launch web server
kubectl run nginx --image=nginx 

# wait
sleep 5

# Prove that is it a steady Pod like any other
kubectl exec nginx -- date

# Establish port-forwarding
kubectl port-forward nginx 1080:80

# Experiments
#
# - Watch logs using `kubectl logs -f nginx`
# - Generate web requests using `curl http://127.0.0.1:1080`
# - Attach to nginx using `kubectl attach nginx` 
#      (and generate more web requests!)
# - Dettach by pressing CTRL+C
# - Destroy Pod