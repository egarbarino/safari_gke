#/bin/sh

# Run this command to observe the creation and destruction
# of disks during the creation and destruction of 
# Kubernetes clusters
watch gcloud compute disks list
