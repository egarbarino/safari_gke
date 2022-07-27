#!/bin/sh

# Run this on a different pane/window to see virtual
# machine activity when creating/destroying
# Kubernetes clusters.
watch gcloud compute instances list
