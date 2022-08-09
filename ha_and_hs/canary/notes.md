## Canary and Zero Downtime Releases

### Canary

Watch myservice's endpoints in a different pane

```
watch -n1 kubectl get service/myservice
```

Watch Pods so that they show their `prod` label

```
watch -n1 kubectl get pods -L prod
```

Explore and apply manifest (note label selector)

```
kubect create -f myservice.yaml
```

Create a service targeting Pods whose label `prod` is set to `true`

```
kubectl run v1 --image=nginx --port=80 --replicas=3 --labels="prod=true"
```    

Wait until External IP is assigned to service and fetch version using

```
curl -I -s http://IP_ADDRESS | grep Server
```

Keep polling the web server on a different pane:

```
while true ; do curl -I -s http://IP_ADDRESS | grep Server ; done
```

Create new deployment in which we use Apache rather than Nginx

```
kubectl create deployment v2 --image=httpd --port=80 --replicas=3 --labels="prod=false"
```

Note that `prod=false`

Pick a random Pod and change its label to `prod=true`:

```
kubectl label pod/NAME prod=true --overwrite
```

Notice that one IP address will have joined `myservice`

Keep changing the label of Pods until all of them have `prod=true`

Delete the old nginx deployment so that requests are only served by Apache

```
kubectl delete deployment/v1
```

### Zero-downtime Deployments

Delete all previous deployments and services

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
while true ; do curl -s -I http://IP_ADDRESS | grep Server; sleep 1 ; done
```

Change base image to Apache's

```
kubectl set image deploy/site site=httpd
```

Understand that applying a new manifest would cause the same effect







