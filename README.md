# Kubernetes on GKE (Introduction)
Source: []()

This repo contains the code examples used in the live course 
titled 'Kubernetes on GKE', held on the [O'Reilly's platform](https://www.oreilly.com/).

**How To Use Code Examples**

The examples are meant to followed in a _relative_ sequential
fashion, but many of them suggest the set up of 'watchers' or steady
monitoring scripts in different windows/panels/panes/tabs/etc. Others,
instead may require user interaction.

In addition, the comments may suggest further experimentation beyond
the directly executable scripts.
# Getting Started With GKE
Source: [getting_started](getting_started)





## Setting up The Google Cloud Shell and GKE
Source: [getting_started/initialization](getting_started/initialization)

[Source](getting_started/initialization)

Learning objectives:

- Learn how to access the Google Cloud Shell
- Learn how to set the project id and compute zone
- Learn how to enable access to Kubernetes services

 Setting up The Google Cloud Shell and GKE

### Google Cloud Platform

Fundamentals

1. Create an account at [https://cloud.google.com/](https://cloud.google.com/)
2. Set up billing (e.g., enter your credit card)
3. Create a project (we use 'safari-gke' in our examples)
4. Associate billing with the project

### Google Cloud Shell

Tmux (Optional)

Create file `.tmux.conf` and add the below line to have
the status bar visible at all times:

```
set -g status on
```

Project (Optional)

Add the below line to the end of `.bashrc` 
in your home directory to avoid setting the 
project for every session:

```
gcloud config set project safari-gke
```

## Creating and Destroying Kubernetes Clusters
Source: [getting_started/cluster](getting_started/cluster)

Learning objectives:

- Learn how to monitor Kubernetes cluster creation activity
    - Supervisor node
    - Worker node
    - Disks
- Learn how to launch a Kubernetes cluster
- Learn how to destroy a Kubernetes cluster

### Create Cluster

Set up four panes in TMUX 

1. Pane 1 - Monitor clusters: `watch gcloud container clusters list`
2. Pane 2 - Monitor compute: `watch gcloud compute instances list`
3. Pane 3 - Monitor disks: `watch gcloud compute disks list`
4. Pane 4 - Run ad-hoc commands here

Create Kubernetes cluster

```
gcloud container clusters create my-cluster \
   --zone europe-west2-a \
   --project safari-gke
```

### Introduce Nodes and Objects

```
ls -la ~/.kube
kubectl version
kubectl get node
kubectl get node -o wide
kubectl explain node
kubectl get node/XXX -o yaml
```

### Destroy Cluster

Destroy Kubernetes cluster (optional)

```
gcloud container clusters delete my-cluster --async --quiet --zone europe-west2-a
```



## Launching Docker Containers Using Pods
Source: [getting_started/launching_pods](getting_started/launching_pods)

Learning objectives:

- Learn how to monitor Pod activity
- Learn about docker image registries: Google's vs Docker Hub
- Learn how to run a one-off command 
    - Using a Google Registry's docker image
    - Using a Docker Hub's docker image 
    - Pipe data to command
- Learn how to open a shell inside a one-off Pod's container
- Learn how to launch 'steady' Pods
    - Beginner's trap 
    - The right way 
    - Running commands on steady Pod
    - Opening shells on steady Pod
- Learn how to launch a web server
    - Learn how to monitor the web server's logs
    - Learn how to attach to the main server's process
    - Learn how to access the web server's port locally
- Learn how to define Pods using manifests



### Watch Pod Activity

Set up a new pane and run `watch -n 1 kubectl get pod`

### Decide on a Docker Image Registry

* Docker Hub is assumed by default
* Otherwise, Google Container Registry's public images may be used:

```
gcloud container images list --project google-containers
```

### Run a Single Command


Obtain date using Google Registry's Busybox image

```
kubectl run my-pod --image=gcr.io/google-containers/busybox --restart=Never --attach --rm date
```

Obtain date using Docker Hub's alpine image

```
kubectl run my-pod --image=alpine --restart=Never --attach --rm date
```

Passing arguments using -i flag

```
echo /etc/resolv.conf | kubectl run my-pod --restart=Never --image=alpine -i --rm wc
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

Establish port-forwarding

```
kubectl port-forward nginx 1080:80
```

Experiments

- Watch logs using `kubectl logs -f nginx`
- Generate web requests using `curl http://127.0.0.1:1080`
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
    --dry-run=client -o yaml > nginx.yaml
```  

Create (or Apply)

```
kubectl create -f nginx.yaml
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




## Managing Pods' Life Cycle
Source: [getting_started/life_cycle](getting_started/life_cycle)

Learning objectives:

- Altert a container's startup command and arguments
- Limit container's RAM and CPU usage


### Override (or Specify) Container Startup

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

### Specify CPU and RAM Limits

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

### Pod Volumes and Volume Mounts

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


### PostStart and PreStop Hooks

1. View contents of `life_cycle.yaml`
2. Notice `lifecycle.postStart` and `lifecycle.preStop`
3. Make sure a disk called my-disk exists (`create_disk.sh`)
4. Run `kubectl create -f life_cycle.yaml`
5. Check logs via `kubectl exec -ti my-pod -- cat /data/log.txt`
6. Kill my-pod via `kubectl delete pod/my-pod` and go to step 4



