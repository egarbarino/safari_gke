## Creating and Destroying Kubernetes Clusters

Learning objectives:

- Learn how to monitor Kubernetes cluster creation activity
    - Supervisor node
    - Worker node
    - Disks
- Learn how to launch a Kubernetes cluster
- Learn how to destroy a Kubernetes cluster

### Create Cluster

Set up four panes in TMUX 

1. Pane 1 - Monitor clusters: `watch gcloud container clusters list`
2. Pane 2 - Monitor compute: `watch gcloud compute instances list`
3. Pane 3 - Monitor disks: `watch gcloud compute disks list`
4. Pane 4 - Run ad-hoc commands here

Create Kubernetes cluster

```
gcloud container clusters create my-cluster \
   --zone europe-west2-a \
   --project safari-gke
```

### Introduce Nodes and Objects

```
ls -la ~/.kube
kubectl version
kubectl get node
kubectl get node -o wide
kubectl explain node
kubectl get node/XXX -o yaml
```

### Destroy Cluster

Destroy Kubernetes cluster (optional)

```
gcloud container clusters delete my-cluster --async --quiet --zone europe-west2-a
```



