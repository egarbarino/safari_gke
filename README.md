# Kubernetes on GKE

This repo contains the code examples used in the live course 
titled 'Kubernetes on GKE', held on the Safari Online platform.

## Getting Started With GKE

## Initial Setup

### Google Cloud Platform

Fundamentals

1. Create an account at [https://cloud.google.com/](https://cloud.google.com/)
2. Set up billing (e.g., enter your credit card)
3. Create a project (we use 'safari-gke' in our examples)
4. Associate billing with the project

Tmux (Optional)

Create file `.tmux.conf` and add the below line to have
the status bar visible at all times:

```
set -g status on
```

Project (Optional)

Add the below line to `.profile` in your home directory
to avoid setting the project for every session:

```
gcloud config set project safari-gke
```

### How To Use Code Examples

The examples are meant to followed in a _relative_ sequential
fashion, but many of them suggest the set up of 'watchers' or steady
monitoring scripts in different windows/panels/panes/tabs/etc. Others,
instead may require user interaction.

In addition, the comments may suggest further experimentation beyond
the directly executable scripts.


### Setting up The Google Cloud Shell and GKE

Learning objectives:

- Learn how to access the Google Cloud Shell
- Learn how to set the project id and compute zone
- Learn how to enable access to Kubernetes services

#### Init

Source: [getting_started/initialization/init.sh](getting_started/initialization/init.sh)

``` bash
#/bin/sh
# Set your project
gcloud config set project safari-gke

# Set your preferred compute zone
gcloud config set compute/zone europe-west2-a

# Enable GKE service
# This won't work unless Billing is enabled and associated to your project
# (for example, safari-gke)
gcloud services enable container.googleapis.com

```

### Creating and Destroying Kubernetes Clusters

Learning objectives:

- Learn how to launch a Kubernetes cluster
- Learn how to destroy a Kubernetes cluster
- Learn how to monitor the process (do this first!)

#### Watch Cluster

Source: [getting_started/cluster/watch_cluster.sh](getting_started/cluster/watch_cluster.sh)

``` bash
#!/bin/sh

# Run this on a different pane/window to see virtual
# machine activity when creating/destroying
# Kubernetes clusters.
watch gcloud container clusters list
```

#### Watch Compute

Source: [getting_started/cluster/watch_compute.sh](getting_started/cluster/watch_compute.sh)

``` bash
#!/bin/sh

# Run this on a different pane/window to see virtual
# machine activity when creating/destroying
# Kubernetes clusters.
watch gcloud compute instances list
```

#### Watch Disks

Source: [getting_started/cluster/watch_disks.sh](getting_started/cluster/watch_disks.sh)

``` bash
#/bin/sh

# Run this command to observe the creation and destruction
# of disks during the creation and destruction of 
# Kubernetes clusters
watch gcloud compute disks list
```

#### Create Cluster

Source: [getting_started/cluster/create_cluster.sh](getting_started/cluster/create_cluster.sh)

``` bash
#/bin/sh
gcloud container clusters create my-cluster \
   --zone europe-west2-a
```

#### Delete Cluster

Source: [getting_started/cluster/delete_cluster.sh](getting_started/cluster/delete_cluster.sh)

``` bash
#/bin/sh

# Delete Kubernetes cluster called my-cluster
gcloud container clusters delete my-cluster --async --quiet --zone europe-west2-a
```

