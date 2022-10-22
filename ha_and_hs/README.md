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

```
In a few moments, we will see that even though Deployments control ReplicaSets, and ReplicaSets control Pods, neither ReplicaSets nor Pods are declared separately. Both ReplicaSets and Pods are 'spawned' from a single Deployment manifest or imperative 'kubectl create deployment' command. Wait a couple of minutes, and let me know your opinion about Deployments.
```

```
👍 It is a mechanism to define both scaling and image versioning properties applicable to a fleet of Pods 😲 I should have been called 'Scaling', 'Version' controller, or 'ScalingVersion' controller 👎 I was so happy with simple naked Pods
```



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

```
Do you have experience with traditional blue/green deployments in bare metal data centers? https://martinfowler.com/bliki/BlueGreenDeployment.html
```

```
👍 Yes, this is how we do things at work 😲 I believe it is something that some enterprises do to minimise downtime 👎 First time I’m learning about blue/green deployments but I'll check the link
```

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

```
What does come to mind when you hear the word 'auto-scaling'?
```

```
👍 Many Pods popping up like Gremlins 😲 Not having to worry during peak periods such as Black Friday 👎 A threat to my 'load forecasting' job
```

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

```
A service controller is the mechanism by which Kubernetes creates a 'load balancer', or a 'round robin' mechanism to access a fleet of Pods. Why do you think the Pod-to-Pod use case is relevant?
```

```
👍 In the 'microservices' age, most applications consist of various interconnected Pods 😲 I'm surprised that even internal Pods may come as 'fleets' 👎 It is much easier to interconnect monolithic Pods with hard-coded IP addresses
```

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

```
The Service controller implements a soft 'load balancer' as far as round robin is concerned, but the 'Internet to Pod' use case, necesites the interaction with the actual Google Cloud Platform's 'load balancer' resource (and underlying network infrastructure). Why do you think this is?
```

```
👍 Because traffic needs to flow from the public internet into GCP, and then into GKE (within GCP) 😲 Because assigning public IP addresses falls outside the scope of Kubernetes 👎 I thought Kubernetes was fully self-contained and portable across all clouds
```

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

```
What is the most important thing, in your opinion, for the release of a new application version? (No right answer!)
```

```
👍 That once the user lands on the new version, they stay on it 😲 That the user never experiences downtime even though they may intermittently see two different versions 👎 Nothing. I prefer large downtime windows on Sunday nights.
```

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





