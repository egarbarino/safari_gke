## Publishing Services on the Public Internet

Create a service of type LoadBalancer

```
kubectl expose deploy/nginx --name nginx3 --type=LoadBalancer --port=80
```

Explore `serviceLoadBalancer.yaml` and apply it


```
kubectl create -f serviceLoadBalancer.yaml
```

Wait for the external IP to be seen on the pane in which `kubectl get service` is being refreshed

