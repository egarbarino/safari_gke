## Launching Deployments

Set up monitoring in different panes

```
watch kubectl get deployment
watch kubectl get replicaset
watch kubectl get pod
```

Create deployment

```
kubectl create deployment nginx --image-nginx
```

Delete deployment

```
kubectl delete deployment/nginx
```

Specify number of replicas 

```
kubectl create  deployment --image=nginx --replicas=3
```

### Scaling

Scale number of replicas

```
kubectl scale deploy/nginx --replicas=5
```

### Updating Docker Image

Update the pod's image

```
kubectl set image deploy/nginx nginx=nginx:1.9.1
```

Understand shown in `kubectl get deployments`

* DESIRED: The target state: specified in deployment. spec.replicas
* CURRENT: The number of replicas running but not necessarily available: specified in deployment.status. replicas
* UP-TO-DATE: The number of Pod replicas that have been updated to achieve the current state: specified in deployment.status.updatedReplicas
* AVAILABLE: The number of replicas actually available to users: specified in deployment.status. availableReplicas
* AGE: The amount of time that the deployment controller has been running since first created

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

### Monitoring and Controlling a Deployment

Run on a different pane:

```
kubectl rollout status deployment/nginx
```

Now create a deployment

```
kubectl create deployment nginx --image=nginx --replicas=12
```

Puase the deployment

```
kubectl rollout pause deploy/nginx
```

Resume the deplyment

```
kubectl rollout resume deploy/nginx
```


















