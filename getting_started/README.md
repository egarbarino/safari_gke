# S1 Getting Started With GKE

## GCP Beginners Only Section

Fundamentals

1. Create an account at [https://cloud.google.com/](https://cloud.google.com/)
2. Set up billing (e.g., enter your credit card)
3. Create a project (we use 'safari-gke' in our examples)
4. Associate billing with the project

Set up TMUX 

Create file `.tmux.conf` and add the below line to have
the status bar visible at all times:

```
set -g status on
```

Command Prompt 

Set a shorter command prompt if useful:

```
export PS1='$ '
```

## S1.1 Setting up The Google Cloud Shell and GKE

### Access Google Cloud Shell

Browse [https://cloud.google.com/](https://cloud.google.com/) and click on the Google Cloud Shell Icon

Why?

- gcloud
- kubectl
- python

### Login If Not Running in Cloud Shell

```
gcloud components install kubectl
gcloud auth login
```

### Set up project

```
gcloud config set project safari-gke
```

Note: You may add it to `~/.bashrc`

### Enable Container Service

```
gcloud services enable container.googleapis.com
```

_end of section_

---


## S1.2 Creating and Destroying Kubernetes Clusters

### Create Cluster (All)

Scripts: `create_cluster.sh`

Set up four panes in TMUX 

1. Pane 1 - Monitor clusters: `watch gcloud container clusters list`
2. Pane 2 - Monitor compute: `watch gcloud compute instances list`
3. Pane 3 - Monitor disks: `watch gcloud compute disks list`
4. Pane 4 - Run ad-hoc commands here

Optionally, create a new TMUX window to get global telemetry:

1. Pane 1 - `watch kubectl get events -w`
2. Pane 2 - `watch kubectl top node`
3. Pane 3 - `watch kubectl top pod`


### Create Cluster (Course)

```
./create_cluster.sh
ls -la ~/.kube
```

### Create Cluster (Student Only)

```
gcloud container clusters create my-cluster \
   --zone europe-west2-a \
   --project safari-gke
```

### Docker Hub Request Limit Fix

```
./docker_hub_fix.sh
```

### Introduce Nodes and Objects

* Everything is an object

```
kubectl version --short
kubectl get node
kubectl get node -o wide
kubectl explain node
kubectl get node/XXX -o yaml
```

### Destroy Cluster

Scripts: `delete_cluster.sh`

Destroy Kubernetes cluster (Student Only)

```
gcloud container clusters delete my-cluster --async --quiet --zone europe-west2-a
```

## S1.3 Launching Docker Containers Using Pods

### Watch Pod Activity

Open a new TMUX window

Pane 1. Run `watch -n 1 kubectl get pod`
Pane 2. Run `kubectl get -w events`
Pane 3. Run commands here

### Decide on a Docker Image Registry

* Docker Hub is assumed by default
* Otherwise, Google Container Registry's public images may be used:

### Using GCR.IO (Student Only)

```
gcloud container images list --project google-containers
kubectl run my-pod --image=gcr.io/google-containers/busybox --restart=Never --attach --rm date
```

### Run a Single Command

Obtain date using Docker Hub's alpine image

```
kubectl run my-pod --image=alpine --restart=Never --attach --rm date
```


### Run a One-Off Shell

```
kubectl run my-pod --image=alpine --restart=Never -it --rm sh
```

Experiments inside shell

- Launch various background processes such as 'sleep 30 &'
- Try hostname
- Fetch an Internet resource using 'wget'
- Check IP address using 'ifconfig eth0' and 

Experiments outside

Show 'kubectl get pod/my-pod -o yaml' outside

### Running 'Steady' Pods

**This won't work**

This command won't complete. The pod will keep crashing
and will need to be killed with `kubectl delete pod/my-pod`

```
kubectl run my-pod --image=alpine sh 
```

**This works instead**

This will leave Pod running in the background

```
kubectl run my-pod --image=alpine sleep infinity 
```

Run `date` on container

```
kubectl exec my-pod -- date
```

Run `ls -l` on container

```
kubectl exec my-pod -- ls -l
```


Open shell

```
kubectl exec my-pod -ti -- sh
```

Experiments

- Exit and enter shell again 
- Delete Pod

### Running a Web Server

Launch web server

```
kubectl run nginx --image=nginx 
```

Prove that is it a steady Pod like any other

```
kubectl exec nginx -- date
```

Pane 2: Watch logs

```
kubectl logs -f nginx
```

Pane 3: Establish port-forwarding

```
kubectl port-forward nginx 8080:80
```

Experiments

- Generate web requests using `curl http://127.0.0.1:8080`
- Attach to nginx using `kubectl attach nginx` (and generate more web requests!)
- Dettach by pressing CTRL+C
- Destroy Pod

### Pod Manifest

Kubectl run can be seen as creating a Pod manifst on the fly

```
kubectl run nginx --image=nginx --restart=Never \
    --dry-run=client -o yaml
```   

Save manifest

```
kubectl run nginx --image=nginx --restart=Never \
    --dry-run=client -o yaml > /tmp/nginx.yaml
```  

Create (or Apply)

```
kubectl create -f /tmp/nginx.yaml
```

* Copy `ngninx.yaml` to `nginx-clean.yaml`
* Edit `nginx.yaml` 
* Note that `status` is empty. 
* Use `kubectl explain` to understand the meaning of each attribute.

``` yaml
# nginx-clean.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
```

* Delete runnin nginx using `kubectl delete pod/nginx` or `kubectl delete -f nginx.yaml` before applying
* Run `kubectl apply -f nginx-clean.yaml`

#### Port Numbers and Environment Variables

* Many applications require settings to be placed in environment variables
* For example, MYSQL's root password

``` yaml
# mysql.yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql
spec:
  containers:
  - image: mysql
    name: mysql
    ports:
    - containerPort: 3306
      name: mysql
      protocol: TCP
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: mypassword
```

* Run `kubectl apply -f mysql.yaml`
* Access MYSQL

``` 
echo "show databases" | kubectl exec -i mysql \
    -- mysql --password=mypassword
```

_end of session_

---

## S1.4 Managing Pod Life Cycle

### Pod Volumes and Volume Mounts

```
kubectl explain pod.spec.volumes
```

* `emptyDir` - A temporary file system so that containers within a single Pod can exchange data.
* `hostPath` - A directory within the Node's file system 
* A network storage device such as a Google Cloud Storage volume (referred as gcePersistentVolume) or a NFS server.

#### hostPath 

* It survives the deletion of a Pod but it is tied up to the node
* There is no guarantee that the Pod will be scheduled to the same node

#### External Volumes and Google Cloud Storage

Create a disk (scripts: `create_disk.sh` and `delete_disk.sh`)

```
gcloud compute disks create my-disk --size=10GB \
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

### Startup Arrguments, PostStart and PreStop Hooks

1. View contents of `life_cycle.yaml`
2. Notice `lifecycle.postStart` and `lifecycle.preStop`
3. Make sure a disk called my-disk exists (`create_disk.sh`)
4. Run `kubectl create -f life_cycle.yaml`
5. Check logs via `kubectl exec -i my-pod -- cat /data/log.txt`
6. Kill my-pod via `kubectl delete pod/my-pod` and go to step 4

_end of section_

---

## S1.5 Implementing Self-Healing Mechanisms

### Implementing Readiness and Liveness Probes

1. Open `nginx-advanced.yaml`
2. Run manfiest via `kubectl create -f nginx-advanced.yaml`
3. Notice the readiness probe's failure
4. Fix the issue: `kubectl exec -ti pod/nginx -- touch /ready.txt`
5. Delete index.html: `kubectl exec -ti nginx -- rm /usr/share/nginx/html/index.html`
6. Notice Pod being restarted

Optional

Use `kubectl describe pod/nginx` for diagnosis

_end of segment_

