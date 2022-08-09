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

### Namespaces

* Help group and secure resources
* Help segregate Kubernetes resources from user-defined resources

#### Default vs Kubernetes Namespaces

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

#### All Namespaces

You can get resources in all namespaces using the `--all-namespaces` or `-A`

```
kubectl get pod --all-namespaces
kubectl get pod -A
```

#### Custom Namespaces

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

1. Show lanels on your pod monitoring tab: `kubectl get pod --show-labels`

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



# High Availability and High Scalability
Source: [ha_and_hs](ha_and_hs)

## Launching Deployments
Source: [ha_and_hs/launching_deployments](ha_and_hs/launching_deployments)

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


















## Rolling and Blue/Green Deployments
Source: [ha_and_hs/strategies](ha_and_hs/strategies)

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


## Rolling Back Deployments
Source: [ha_and_hs/roll_back](ha_and_hs/roll_back)

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





## Instrumenting Static Scaling and Autoscaling
Source: [ha_and_hs/scaling](ha_and_hs/scaling)

* We've covered static scaling already using the 'replicas' attribute, both imperatively or declaratively
* Understand the Horizontal Pod Autoscaler (HPA) vs Cluster-wise Scaling

### Setting Up Autoscaling

Note: We assume that the previous nginx deployment is still running

Open a pane to watch the autoscaler first:

```
watch kubectl get hpa
```

Now launch an autoscaler against the nginx deployment

```
kubectl autoscale deployment/nginx --min=1 --max=3 --cpu-percent=5
```

Explore declarative version too (note that this version defines 2 replicas!)

```
vi hpa.yaml
kubectl apply -f hpa.yaml
```

#### Spiking CPU Internally

Generate infinite loop to spike the CPU and see auto-scaling in action. Ensure you pick the name of an actual Pod, rather than the one used below.

```
kubectl exec -it nginx-XXXXX-XXXX -- sh -c 'while true; do true; done'
```

#### Spiking CPU Externally

Install Apache Bench

```
sudo apt-get update
sudo apt-get install apache2-utils
```

Expose the other Pod's TCP port

```
kubectl port-forward nginx-XXXXX-XX 1080:80
```

Generate one million requests against it:

```
ab -n 1000000 -c 100 http://localhost:1080
```

### Cluster-wise Scaling

* Understand that the trigger is insufficient Pod resources rather than CPU (book)

Create a new cluster with auto-scaling enabled

```
gcloud container clusters create scalable-cluster \
    --num-nodes=3 \ 
    --enable-autoscaling \
    --min-nodes 3 \ 
    --max-nodes 6
```

Create a significant number of nodes:

```
kubectl run nginx --image=nginx --replicas=30
```

See the cluster auto-scale:

```
watch kubectl get nodes
```


















## Understanding Service Discovery Use Cases
Source: [ha_and_hs/service_discovery_use_cases](ha_and_hs/service_discovery_use_cases)

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

## Publishing Services on the Public Internet
Source: [ha_and_hs/service_public_internet](ha_and_hs/service_public_internet)

Create a service of type LoadBalancer

```
kubectl expose deploy/nginx --name nginx3 --type=LoadBalancer --port=80
```

Explore `serviceLoadBalancer.yaml` and apply it


```
kubectl create -f serviceLoadBalancer.yaml
```

Wait for the external IP to be seen on the pane in which `kubectl get service` is being refreshed

## Canary and Zero Downtime Releases
Source: [ha_and_hs/canary](ha_and_hs/canary)

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







