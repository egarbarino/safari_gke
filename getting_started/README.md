# S1 Getting Started With GKE

## S1.1 Setting up The Google Cloud Shell and GKE

### Google Cloud Platform (First Time Student Only)

Fundamentals

1. Create an account at [https://cloud.google.com/](https://cloud.google.com/)
2. Set up billing (e.g., enter your credit card)
3. Create a project (we use 'safari-gke' in our examples)
4. Associate billing with the project

### Access Google Cloud Shell

Browse [https://cloud.google.com/](https://cloud.google.com/) and click on the Google Cloud Shell Icon

Why?

- gcloud
- kubectl
- python

### Set up project

Add the below line to the end of `.bashrc` in your home directory to avoid setting the 
project for every session:

```
gcloud config set project safari-gke
```

### Set up TMUX

Set tup tmux

Create file `.tmux.conf` and add the below line to have
the status bar visible at all times:

```
set -g status on
```

### Command Prompt

Set a shorter command prompt if useful:

```
export PS1='$ '
```

### Enable Container Service

```
gcloud services enable container.googleapis.com
```

## S1.2 Creating and Destroying Kubernetes Clusters

### Create Cluster (All)

Scripts: `create_cluster.sh`

Set up four panes in TMUX 

1. Pane 1 - Monitor clusters: `watch gcloud container clusters list`
2. Pane 2 - Monitor compute: `watch gcloud compute instances list`
3. Pane 3 - Monitor disks: `watch gcloud compute disks list`
4. Pane 4 - Run ad-hoc commands here


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

### Introduce Nodes and Objects

* Everything is an object

```
ls -la ~/.kube
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

Pane 1. Run `watch -n 1 kubectl get pod`

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

Passing arguments using -i flag

```
echo /etc/resolv.conf | kubectl run my-pod --image=alpine --restart=Never -i --rm -- wc
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

Pipe data

```
cat /etc/resolv.conf | kubectl exec -i my-pod -- wc 
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

#### Network Ports

* Not mandatory but good hygene
* Naming ports is a necessity when multiple ones are in use
* Copy `nginx-clean.yaml` to `nginx-ports.yaml`
* Add the following content:

``` yaml
# nginx-port.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
      name: http
      protocol: TCP
```

#### Environment Variables

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

### Namespaces (Student Only)

* Help group and secure resources
* Help segregate Kubernetes resources from user-defined resources

#### Default vs Kubernetes Namespaces (Student Only)

Unless otherwise specified, the _default_ namespace is assumed.

Launch some workload

```
kubectl run nginx --image=nginx 
```

Check that getting pods means an implicit `-n default`

```
kubectl get pod
kubectl get pod -n default
```

Checkout what namespaces are defined (`ns` also works)

```
kubectl get namespace
```

List Kube-System's Pods

```
kubectl get pod -n kube-system
```

These are regular containers, for example, open a shell on `kube-dns-*`:

```
kubectl exec -ti kube-dns-56494768b7-4v8rm -n kube-system -- sh
```

Note: You can use `-c` to select the Pod's container

#### All Namespaces (Student Only)

You can get resources in all namespaces using the `--all-namespaces` or `-A`

```
kubectl get pod --all-namespaces
kubectl get pod -A
```

#### Custom Namespaces (Student Only)

For example, for different environments

```
kubectl namespace create dev
kubectl namespace create qa
kubectl namespace create prod
```

```
kubectl run nginx --image=nginx -n dev
kubectl run nginx --image=nginx -n qa
kubectl run nginx --image=nginx -n prod
```

```
kubectl get pod -n dev
kubectl get pod -n qa
kubectl get pod -n prod
kubectl get pod -A | grep nginx
```

### Labels

Key/value pairs to reference a family of related objects (e.g., replicas of the same Pod)

* Version numbers
* Environments (e.g., dev, staging, production)
* Deployment type (e.g., canary release or A/B testing

```
kubectl run nginx --image=nginx
kubectl get pods --show-labels
```

#### Defining Labels in Pod Manifest

Pane 1: Show lanels on your pod monitoring tab: `kubectl get pod --show-labels`

Explore `nginx-labels.yaml`

Apply manifest:

```
kubectl create -f nginx-labels.yaml
```

Define labels imperatively

```
kubectl run nginx1 --image=nginx -l "env=dev,author=Ernie"
kubectl run nginx2 --image=nginx -l "env=dev,author=Mohit"
```

Change monitoring window to show labels as columns:

```
kubectl get pods -L env,author
```

#### Selector Expressions

Equality-based expressions (equality)

```
kubectl get pods -l author=Ernie 
kubectl get pods -l author!=Ernie
kubectl get pods -l 
```

Set-based expressions (membership)

Show pods that contain the label _caution_:

```
kubectl get pods -l caution 
```

Show pods that DO NOT contain the label _caution_:

```
kubectl get pods -l \!caution 
```

More complex expressions

```
kubectl get pods -l "author in (Ernie,Mohit)"
```

Not in set

```
kubectl get pods -l "author notin (Ernie,Mohit)"
```


#### Updating Labels at Runtime

Use --overwrite flag:

```
kubectl label pod/nginx author=Bert --overwrite
kubectl get pods -l "author notin (Ernie,Mohit)"
```

## S1.4 Managing Pod Life Cycle

### Specify CPU and RAM Limits

Why a life cycle concern

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


### Pod Volumes and Volume Mounts

* `emptyDir` - A temporary file system so that containers within a single Pod can exchange data.
* `hostPath` - A directory within the Node's file system 
* A network storage device such as a Google Cloud Storage volume (referred as gcePersistentVolume) or a NFS server.

#### EmptyDir (Student Only)

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

#### hostPath (Student Only)

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

#### External Volumes and Google Cloud Storage

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

### S1.5 Override (or Specify) Container Startup

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

### PostStart and PreStop Hooks

1. View contents of `life_cycle.yaml`
2. Notice `lifecycle.postStart` and `lifecycle.preStop`
3. Make sure a disk called my-disk exists (`create_disk.sh`)
4. Run `kubectl create -f life_cycle.yaml`
5. Check logs via `kubectl exec -ti my-pod -- cat /data/log.txt`
6. Kill my-pod via `kubectl delete pod/my-pod` and go to step 4



## Implementing Self-Healing Mechanisms
Source: [getting_started/self-healing](getting_started/self-healing)

### Concepts

Health Probe Types:

- Readiness Probes
- Liveness Probes

Health Check Types

- Command-based
- HTTP-based
- TCP-based

### Implementing Liveness Probe

1. Notice `livenessProbe` on `nginx-liveness.yaml`
2. Run manifest: `kubectl create -f nginx-liveness.yaml`
3. (Optionally) test web server using `kubectl port-forward nginx 1080:80` and `curl -i -s http://localhost:1080 | head -n 1`
4. Delete index.html: `kubectl exec -ti nginx -- rm /usr/share/nginx/html/index.html`
4. Notice Pod being restarted
5. Use `kubectl describe pod/nginx` to find out more details

### Implementing Readiness Probe

1. Notice `readinessProbe` on `nginx-advanced.yaml`
2. Watch events on a different window via `kubectl get events -w`
3. Notice the readiness probe's failure
4. Fix the issue: `kubectl exec -ti pod/nginx -- touch /ready.txt`

Extra (Advanced settings for Liveness Probe)

1. Delete index with `kubectl exec ti pod/nginx -- rm /usr/share/nginx/html/index.html`
2. Notice 5 failures on the event window followed by a restart

