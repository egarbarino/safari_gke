#/bin/sh
# Set your project
gcloud config set project safari-gke

# Set your preferred compute zone
gcloud config set compute/zone europe-west2-a

# Enable GKE service
# This won't work unless Billing is enabled and associated to your project
# (for example, safari-gke)
gcloud services enable container.googleapis.com

