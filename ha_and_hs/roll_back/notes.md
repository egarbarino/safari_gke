## Rolling Back Deployments

Note: This section assumes that the nginx deployment updates launched in the previous sections are still active:

List rollout history on a different panel

``` 
watch kubectl rollout history deploy/nginx
```

Undo the last deployment

```
kubectl rollout undo deploy/nginx
```

Undo to a specific revision:

```
kubectl rollout undo deploy/nginx --to-revision=2
```





