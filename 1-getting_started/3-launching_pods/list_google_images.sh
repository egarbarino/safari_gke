#!/bin/sh

# Docker images available from Google's own container registry
# which can be use to avoid Docker Hub's rate limiting issues
gcloud container images list --project google-containers
