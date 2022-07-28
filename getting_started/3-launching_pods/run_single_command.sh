#!/bin/sh

# Obtain date using Google Registry's Busybox image
kubectl run my-pod --image=gcr.io/google-containers/busybox --restart=Never --attach --rm date

# Obtain date using Docker Hub's alpine image
kubectl run my-pod --image=alpine --restart=Never --attach --rm date

# Passing arguments using -i flag
echo /etc/resolv.conf | kubectl run my-pod --restart=Never --image=alpine -i --rm wc


