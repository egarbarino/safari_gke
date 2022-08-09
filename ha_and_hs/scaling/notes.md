## Instrumenting Static Scaling and Autoscaling

* We've covered static scaling already using the 'replicas' attribute, both imperatively or declaratively
* Understand the Horizontal Pod Autoscaler (HPA) vs Cluster-wise Scaling

### Setting Up Autoscaling

Note: We assume that the previous nginx deployment is still running

Open a pane to watch the autoscaler first:

```
watch kubectl get hpa
```

Now launch an autoscaler against the nginx deployment

```
kubectl autoscale deployment/nginx --min=1 --max=3 --cpu-percent=5
```

Explore declarative version too (note that this version defines 2 replicas!)

```
vi hpa.yaml
kubectl apply -f hpa.yaml
```

#### Spiking CPU Internally

Generate infinite loop to spike the CPU and see auto-scaling in action. Ensure you pick the name of an actual Pod, rather than the one used below.

```
kubectl exec -it nginx-XXXXX-XXXX -- sh -c 'while true; do true; done'
```

#### Spiking CPU Externally

Install Apache Bench

```
sudo apt-get update
sudo apt-get install apache2-utils
```

Expose the other Pod's TCP port

```
kubectl port-forward nginx-XXXXX-XX 1080:80
```

Generate one million requests against it:

```
ab -n 1000000 -c 100 http://localhost:1080
```

### Cluster-wise Scaling

* Understand that the trigger is insufficient Pod resources rather than CPU (book)

Create a new cluster with auto-scaling enabled

```
gcloud container clusters create scalable-cluster \
    --num-nodes=3 \ 
    --enable-autoscaling \
    --min-nodes 3 \ 
    --max-nodes 6
```

Create a significant number of nodes:

```
kubectl run nginx --image=nginx --replicas=30
```

See the cluster auto-scale:

```
watch kubectl get nodes
```


















