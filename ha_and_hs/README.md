# S2 High Availability and High Scalability

## S2.1 Launching Deployments

Cd to folder `ha_and_hs`:

Set up monitoring in different panes

```
|------------------|
|        1         |
|------------------|
|        2         |
|------------------|
| 3.left | 3.right | 
|------------------|
|        4         |
--------------------
```

* Pane 1: `watch -n 1 kubectl get pod -o wide`
* Pane 2: `watch -n 1 kubectl get replicaset`
* Pane 3.left: `watch -n 1 kubectl get deployment`
* Pane 3.right: Leave empty for now
* Panel 4: ad-hoc commands

Create deployment

```
kubectl create deployment nginx --image=nginx
```

Delete deployment

```
kubectl delete deployment/nginx
```

Specify number of replicas 

```
kubectl create deployment nginx --image=nginx --replicas=3
```

### Updating Docker Image

Update the pod's image

```
kubectl set image deploy/nginx nginx=nginx:1.9.1
```

### Deployment Manifest

Open `simpleDeployment.yaml`

Note the following:

* Pod description is embeded under `template`
* Note replicas
* Note `selector.matchLabels` and relationship with Pod

Create deployment and note simlar result as `kubectl create deployment create ...`

```
kubectl apply -f simpleDeployment.yaml
```

_end of section_

Further details at: https://garba.org/posts/2020/k8s-life-cycle/

---

## S2.2 Rolling and Blue/Green Deployments

Delete previous deployments:

```
kubectl delete deploy --all
```


### Recreate Deployments

Be sure you have montioring panes for deployments, pods, and replicas.

Note the difference in terms of Nginx versions in `nginx-v1-initial-v1.yaml` and `nginx-v2-recreate.yaml`.

Launch first version:

```
vi nginx-v1-initial.yaml
kubectl apply -f nginx-v1-initial.yaml
```

Apply `v2`, which produces an upgrade to nginx 1.9.1:

```
vi nginx-v2-recreate.yaml
kubectl apply -f nginx-v2-recreate.yaml
```

Observe all Pods being killed before producing the update

### One at a time Rolling Updates 

* Both progressive and blue/green deployments are implemented using the same approach
* Understand `maxSurge` vs `maxUnavailable` (book, slides)

```
vi nginx-v3-rolling-one-at-a-time.yaml
kubectl apply -f nginx-v3-rolling-one-at-a-time.yaml
```

### Blue/Green Update

```
vi nginx-v4-blue-green.yaml
sleep 5 ; kubectl apply -f nginx-v4-blue-green.yaml
```

_end of section_

Further details at: https://garba.org/posts/2020/k8s-life-cycle/

---


## S2.3 Rolling Back Deployments

Note: This section assumes that the nginx deployment updates launched in the previous sections are still active:

Pane 3.right: `watch kubectl rollout history deploy/nginx-declarative`

Undo the last deployment

```
kubectl rollout undo deploy/nginx-declarative
```

Undo to a specific revision:

```
kubectl rollout undo deploy/nginx-declarative --to-revision=2
```

_end of section_

---

## S2.4 Instrumenting Static Scaling and Autoscaling

Delete everything and launch a new deployment

```
kubectl delete deploy --all
vi nginx-limited.yaml
kubectl apply -f nginx-limited.yaml 
kubectl scale deploy/nginx-declarative --replicas=3
kubectl scale deploy/nginx-declarative --replicas=5
kubectl scale deploy/nginx-declarative --replicas=1
```


### Setting Up Autoscaling

Note: We assume that the previous nginx deployment is still running

Pane 3.right: `watch -n 1 kubectl get hpa`

Now launch an autoscaler against the nginx deployment

```
kubectl autoscale deployment/nginx-declarative --min=1 --max=3 --cpu-percent=5
```

Explore declarative version too (note that this version defines 2 replicas!)

```
vi hpa.yaml
kubectl apply -f hpa.yaml
```

#### Spiking CPU Internally

Generate infinite loop to spike the CPU and see auto-scaling in action. Ensure you pick the name of an actual Pod, rather than the one used below.

```
kubectl exec -it nginx-XXXXX-XXXX -- sh
```

Inside Pod type this:

```
while true; do true; done
```

#### Spiking CPU Externally (Student Homework)

Install Apache Bench

```
sudo apt-get update
sudo apt-get install apache2-utils
```

Expose the other Pod's TCP port (new window rather than pane)

```
kubectl port-forward nginx-XXXXX-XX 1080:80
```

Generate one million requests against it:

```
ab -n 1000000 -c 100 http://localhost:1080
```

### Cluster-wise Scaling (Student Homework)

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

_end of section_

---

## S2.5 Understanding Service Discovery Use Cases


### Pod-to-Pod Use Case

Delete all previous deployments and Pods

```
kubectl delete all --all
```

Pane 3.right:

```
watch -n1 kubectl get service
```

Create an Nginx deployment

```
kubectl create deployment nginx --image=nginx --replicas=3
```

Explore `update_hostname.sh` and run it:

```
vi update_hostname.sh
./update_hostname.sh
```

Create a service for the deployment

```
kubectl expose deploy/nginx --port=80
```

Explore `service.yaml` which is the declarative version and apply it:

```
kubectl apply -f service.yaml
```

Access nginx from a new Pod

```
kubectl run test --rm -ti --image=alpine --restart=Never -- sh

cwget -q -O - http://nginx 
wget -q -O - http://nginx2 
```

Try wget multiple times to see different hostnames

_end of section_

---


## Publishing Services on the Public Internet

Pane 3.left:

```
watch -n 1 gcloud compute forwarding-rules list 
```

Create a service of type LoadBalancer

```
kubectl expose deploy/nginx --name nginx3 --type=LoadBalancer --port=80
```

Now try public IP address:

```
while true; do curl -s http://IP_ADDRESS ; sleep 1 ; done
```


### Publish Services on the Public Internet (Student Only)

Explore `serviceLoadBalancer.yaml` and apply it

```
vi 
kubectl create -f serviceLoadBalancer.yaml
```

Wait for the external IP to be seen on the pane in which `kubectl get service` is being refreshed

_end of section_

---

## Canary and Zero Downtime Releases


### Canary

Kill previous deployments

```
kubectl delete all --all
```

On pane 1:

```
kubectl get pods -L prod -o wide
```

Create a deployment and apply label prod=true:

```
kubectl create deployment v1 --image=nginx --port=80 --replicas=3 
kubectl label pod prod=true --all
```  

Explore and apply manifest (note label selector)

```
vi myservice.yaml
kubectl apply -f myservice.yaml
```

On pane 3.left:

```
./watch.sh myservice
```

On panel 3.right

```
watch -n 1 "kubectl get endpoints/myservice -o yaml | grep ip" 
```

Create new deployment:

```
kubectl create deployment v2 --image=httpd --port=80 --replicas=3 
```

Note that `prod=false`

Pick a random Pod and change its label to `prod=true`:

```
kubectl label pod/NAME prod=true --overwrite
kubectl label pod prod=true -l \!prod
```

Notice that one IP address will have joined `myservice`

Keep changing the label of Pods until all of them have `prod=true`

Delete the old nginx deployment so that requests are only served by v2

```
kubectl delete deployment/v1
```

### Zero-downtime Deployments

Delete all previous deployments and services

```
kubectl delete all --all
```

Pane 3.right:

```
watch -n 1 kubectl get service
```

Create a new Deployment called `site`

```
kubectl create deployment site --image=nginx --replicas=3
```

Expose deployment and note `--session-affinity`

```
kubectl expose deploy/site --port=80 --type=LoadBalancer --session-affinity=ClientIP
```

Wait for public IP address

Watch server with IP on a different pane

```
./watch.sh site
```

Change base image

```
kubectl set image deploy/site *=httpd
```

Understand that applying a new manifest would cause the same effect

Use `kubectl describe pod/nginx` for diagnosis

_end of segment_





