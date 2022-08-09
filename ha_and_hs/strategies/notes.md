## Rolling and Blue/Green Deployments

### Revision Tracking vs Scaling Only Deployments

Changes in the number of replicas do not result in a deployment revision

Open in a new pane

```
watch kubectl rollout history 
```

Create a deployment and perform 3 scaling updates, 1 image update, and 1 scaling update again

```
kubectl create deployment nginx --image=nginx 
```

```
kubectl scale deploy/nginx --replicas=1
kubectl scale deploy/nginx --replicas=5
kubectl scale deploy/nginx --replicas=3
kubectl set image deploy/nginx nginx=nginx:1.9.1
kubectl scale deploy/nginx --replicas=1
```

### Broad Deployemnt Types

* Recrate: Destroy everything first and only then create the replicas declared by the new Deployment’s manifest
* RollingUpdate: Fine-tune the upgrade process to achieve from something as “careful” as updating one Pod at a time, all the way up to a fully-fledged blue green deployment in which the entire new set of Pod replicas are stood up before disposing of the old ones.

### Recreate

Be sure you have montioring panes for deployments, pods, and replicas.

Note the difference in terms of Nginx versions in `nginx-v1-initial-v1.yaml` and `nginx-v2-recreate.yaml`.

Launch first version:

```
kubectl create -f nginx-v1-initial.yaml
```

Apply `v2`, which produces an upgrade to nginx 1.9.1:

```
kubectl apply -f nginx-recreate-v2.yaml
```

Observe all Pods being killed before producing the update

### Rolling Updates

* Both progressive and blue/green deployments are implemented using the same approach
* Understand `maxSurge` vs `maxUnavailable` (book, slides)


