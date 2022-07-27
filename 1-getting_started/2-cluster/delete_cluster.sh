#/bin/sh

# Delete Kubernetes cluster called my-cluster
gcloud container clusters delete my-cluster --async --quiet --zone europe-west2-a
