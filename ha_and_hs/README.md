# S2 High Availability and High Scalability

Segment TMUX Setup

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

Pane 1

```
watch -n 1 kubectl get pod -o wide
```

Pane 2

```
watch -n 1 kubectl get replicaset
```

Pane 3.left

```
watch -n 1 kubectl get deployment
```

Pane 3.right: Leave empty for now

Panel 4

```
cd ~/safari_gke/ha_and_hs/
```

## S2.1 Launching Deployments


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

_end of section_

Further details at: https://garba.org/posts/2020/k8s-life-cycle/

---

## S2.2 Rolling and Blue/Green Deployments


Pane 3.right:

```
kubectl delete deploy --all
```

### Recreate Deployments

Be sure you have monitoring panes for deployments, pods, and replicas.

Note the difference in terms of Nginx versions in `nginx-v1-initial-v1.yaml` and `nginx-v2-recreate.yaml`.

Launch first version:

```
vi nginx-v1-initial.yaml
```

```
kubectl apply -f nginx-v1-initial.yaml
```


Apply `v2`, which produces an upgrade to nginx 1.9.1:

```
vi nginx-v2-recreate.yaml
```

```
kubectl apply -f nginx-v2-recreate.yaml
```

Observe all Pods being killed before producing the update

### One at a time Rolling Updates 

* Both progressive and blue/green deployments are implemented using the same approach
* Understand `maxSurge` vs `maxUnavailable` (book, slides)

```
vi nginx-v3-rolling-one-at-a-time.yaml
```

```
kubectl apply -f nginx-v3-rolling-one-at-a-time.yaml
```

### Blue/Green Update

```
vi nginx-v4-blue-green.yaml
```

```
sleep 5 ; kubectl apply -f nginx-v4-blue-green.yaml
```

_end of section_

Further details at: https://garba.org/posts/2020/k8s-life-cycle/

---

## S2.3 Instrumenting Static Scaling and Autoscaling


Delete everything and launch a new deployment

```
kubectl delete deploy --all
```

```
vi nginx-limited.yaml
```

```
kubectl apply -f nginx-limited.yaml 
```

Scale first to 3, then to 5, and finally down to 1:

```
kubectl scale deploy/nginx-declarative --replicas=3
```

### Setting Up Autoscaling

Note: We assume that the previous nginx deployment is still running

Pane 3.right

```
watch -n 1 kubectl get hpa
```

Now launch an autoscaler against the nginx deployment

```
kubectl autoscale deployment/nginx-declarative --min=1 --max=3 --cpu-percent=5
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

_end of section_

---

## S2.4 Pod-to-Pod Access


Delete all previous deployments and Pods

```
kubectl delete all --all
```

Pane 3.right:

```
watch -n 1 kubectl get service
```

Create an Nginx deployment

```
kubectl create deployment nginx --image=nginx --replicas=3
```

Explore `update_hostname.sh` and run it:

```
vi update_hostname.sh
```

```
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
```

```
wget -q -O - http://nginx 
```

```
wget -q -O - http://nginx2 
```

Try wget multiple times to see different hostnames

_end of section_

---

## S2.5 Publishing Services on the Public Internet

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

_end of section_

---

## S2.6 Zero Downtime Releases


Pane 3.left: delete all previous deployments and services

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

Pane 3.left: Watch server with IP 

```
cd ~/safari_gke/ha_and_hs/
```

```
cat watch.sh ; sleep 10 ; ./watch.sh site
```

Change base image

```
kubectl set image deploy/site *=httpd
```

Understand that applying a new manifest would cause the same effect

Use `kubectl describe pod/nginx` for diagnosis

_end of segment_





