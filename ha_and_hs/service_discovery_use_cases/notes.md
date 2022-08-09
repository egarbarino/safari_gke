## Understanding Service Discovery Use Cases

### Pod-to-Pod Use Case

Delete all previous deployments and Pods

Open an additional pane to watch services:

```
watch -n1 kubectl get service
```

Create an Nginx deployment

```
kubectl create deployment nginx --image=nginx --replicas=3
```

Explore `update_hostname.sh` and run it:

```
./update_hostname.sh
```


Create a service for the deployment

```
kubectl expose deploy/nginx --port=80
```

Explore `service.yaml` which is the declarative version and apply it:

```
kubectl create -f service.yaml
```

Access nginx from a new Pod

```
kubectl run test --rm -i --image=alpine -- sh

wget -O - http://nginx | grep title
wget -O - http://nginx2 | grep title
```

Try wget multiple times to see different hostnames

#### Internet-to-Pod Connectivity Use Case

