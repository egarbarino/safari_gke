#!/bin/sh
#  This solves the issue with the Docker Hub's rate limit by
#  allowing to pull the images using a specific Docker Hub account.

read -p 'Docker Hub username: ' DOCKER_USERNAME
read -p 'Docker Hub email: ' DOCKER_EMAIL
read -sp 'Docker Hub password: ' DOCKER_PASSWORD

kubectl create secret docker-registry image-pull-secret \
  --docker-server=docker.io \
  --docker-username=$DOCKER_USERNAME \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL

kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "image-pull-secret"}]}'

