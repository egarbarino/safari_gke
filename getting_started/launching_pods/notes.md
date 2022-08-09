## Launching Docker Containers Using Pods

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





