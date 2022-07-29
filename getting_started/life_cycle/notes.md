### Managing Pods' Life Cycle

Learning objectives:

- Altert a container's startup command and arguments
- Limit container's RAM and CPU usage


#### Override (or Specify) Container Startup

* We may want to override the container startup settings
* We may want to specify the container startup settings
* Note '.args' vs '.command' on page 59 of my book 

``` yaml
# alpine-script.yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine
spec:
  containers:
  - name: alpine
    image: alpine
    args:
    - sh
    - -c
    - |
      while true;
        do date;
        sleep 1;
      done
```

* Run `kubectl create -f alpine-script.yaml`
* Follow logs with `kubectl logs -f alpine`

#### Specify CPU and RAM Limits

* We don't want containers to take as much RAM as they want
* We don't want containers to take as much CPU as they want

Example:

``` yaml
# nginx-limited.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
    - image: nginx
      name: nginx
      # Compute Resource Bounds
      resources:
        requests:
          memory: "64Mi"
          cpu: "500m"
        limits:
          memory: "128Mi"
          cpu: "500m"
```

Concepts

* Millicore - a 1000th of a CPU (page 63 of my book)
* Mebi - 1024^2 (page 64 of my book)
* Requests (pre-requisite) - minimum level of compute resources that must be available in a Node before Kubernetes deploys the Pod and associated containers. 
* Limits (max) - maximum level of compute resources that the containers will be allowed to take after they have been deployed into a Node by Kubernetes.

Experiments

* Try excessive values to see what happpens

#### Pod Volumes and Volume Mounts

* `emptyDir` - A temporary file system so that containers within a single Pod can exchange data.
• `hostPath` - A directory within the Node's file system 
• A network storage device such as a Google Cloud Storage volume (referred as gcePersistentVolume) or a NFS server.

**EmptyDir**

* Ideal to share data among containers within the same Pod
* Tied up to the Pod's life cycle. It survives container crashes 
* Contents are lost when Pod is deleted

``` yaml
# alpine-emptyDir.yaml
apiVersion: v1
kind: Pod
metadata:
name: alpine
spec:
  volumes:
    - name: data
      emptyDir:
  containers:
  - name: alpine
    image: alpine
    args:
    - sh
    - -c
    - |
      date >> /tmp/log.txt;
      date >> /data/log.txt;
      sleep 20;
      exit 1; # exit with error
    volumeMounts:
      - mountPath: "/data"
        name: "data"
```

* Run `kubectl apply -f alpine-emptyDir.yaml`
* Compare the dates saved to `/tmp` vs `/data`

```
kubectl exec alpine -- \
    sh -c "cat /tmp/log.txt ; \
    echo "---" ; cat /data/log.txt"
```

* Even though the Pod is crashing, the contents of `emptyDir` are preserved
* Killing the Pod, though will destroy `emptyDir`:

```
kubectl delete -f alpine-emptyDir.yaml
kubectl create -f alpine-emptyDir.yaml
kubectl exec alpine -- cat /data/log.txt
```

**hostPath**

* It survives the deletion of a Pod but it is tied up to the node
* There is no guarantee that the Pod will be scheduled to the same node

``` yaml
# alpine-hostPath.yaml
...
spec:
  volumes:
    - name: data
      hostPath:
        path: /var/data
...
```

**External Volumes and Google Cloud Storage**

Create a disk (scripts: `create_disk.sh` and `delete_disk.sh`)

```
gcloud compute disks create my-disk --size=1GB \
    --zone=europe-west2-a
```

Declare the volume:

``` yaml
# alpine-disk.yaml
...
spec:
  volumes:
    - name: data
      gcePersistentDisk:
        pdName: my-disk
        fsType: ext4
...
```

Modify script to display the contents of /data/log.txt

``` yaml
# alpine-disk.yaml
...
spec:
  containers:
  - name: alpine
    image: alpine
    args:
    - sh
    - -c
    - date >> /data/log.txt; cat /data/log.txt
...
```

Apply manifest see log

```
kubectl create -f alpine-disk.yaml 
kubectl logs alpine
```

Experiments

* Delete cluster (only Pod during live class)
* See that logs are preserved
* Watch the creation of Google disks on a different screen


#### PostStart and PreStop Hooks

1. View contents of `life_cycle.yaml`
2. Notice `lifecycle.postStart` and `lifecycle.preStop`
3. Make sure a disk called my-disk exists (`create_disk.sh`)
4. Run `kubectl create -f life_cycle.yaml`
5. Check logs via `kubectl exec -ti my-pod -- cat /data/log.txt`
6. Kill my-pod via `kubectl delete pod/my-pod` and go to step 4



