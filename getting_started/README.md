# S1 Getting Started With GKE

## Pre-Course Set Up

### Instructor Only

Main Browser

* Tab 1: https://console.cloud.google.com
* Tab 2: https://shell.cloud.google.com/?show=terminal
* Tab 3: https://crontab.guru/

On Tab 2 (Google Cloud Shell)

Create three TMUX Windows (CTRL+B C) and name them (CTRL+B ,) as follows:

0. BEFORE
1. AFTER
3. Main
4. Debugging

### Windows 0 (BEFORE) and 1 (AFTER)

On both Window 0 (BEFORE) and Window 1 (AFTER), set up panes as follows:

```
|------------------|
|        1         |
|------------------|
|        2         |
|------------------|
|        3         | 
|------------------|
|        4         |
--------------------
```

**Note:** Do not run any of the commands yet

Pane 1 - Monitor clusters

```
gcloud container clusters list
```

Pane 2 - Monitor compute

```
gcloud compute instances list | grep NAME
```

Pane 3 - Monitor disks

```
gcloud compute disks list | grep NAME
```

Pane 4 - Cluster Create Command

```
gcloud container clusters delete my-cluster \
	--async \
	--quiet \
	--zone europe-west2-a
```

### Window 0 (BEFORE)

Run only the commands on Panes 1-3 but **not** on Pane 4

### Window 1 (AFTER)

Step 1

Run the `kubectl container clusters create ...` command on Pane 4 and wait until it completes.

Step 2

Run the commands that you pasted on Panes 2-3

Step 3

Run the Docker Hub fix on Window 2 (MAIN):

```
cd ~/safari_gke/getting_started/
```

```
./docker_hub_fix.sh
```

### Window 2 (Main)

```
|------------------|
|        1         |
|------------------|
|        2         |
|------------------|
|        3         | 
|------------------|
|        4         |
--------------------
```

Pane 1: Monitor Pod activity

```
watch -n 1 kubectl get pod
```

Pane 2: Monitor events

```
kubectl get -w events
```

Pane 3: Leave empty

Pane 4: Run commands here


### Window 3 (Debugging)

```
|------------------|
|        1         |
|------------------|
|        2         |
|------------------|
```

Pane 1 - Monitor Events

```
kubectl get -w events
```

Pane 2: - Watch Node Activity

```
watch -n 1 kubectl top node
```

**Get back to Window 2 (Main) before starting**

### Student Only

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

## S0.0 About You

```
A warm welcome to Kubernetes on GKE! Did you know that I used to be an avid traveller? There is a chance that I have visited your country: Argentina, Belgium, Brazil, Cambodia, Canada, Chile, Cuba, Colombia, Costa Rica, Czech Republic, Egypt, France, Germany, Ghana, India, Indonesia, Ireland, Italy, Japan, Luxembourg, Mexico, Morocco, Netherlands, Paraguay, Peru, Portugal, Singapore, Spain, Tanzania, Thailand, United States, United Kingdom, Uruguay, Vietnam.
```

```
👍 Yes, you've been to my country! 😲 You could've visited my country by just crossing the border or taking a ferry!  👎 No, you've missed my wonderful country and I will tell you why you should visit. 
```

## S0.0 Q&A

```
I will answer most of your questions during the final Q&A segment, but I may answer a few during the breaks. Please do not use the Q&A button because I will not see the question after the course ends. Feel free to post questions here as they arise during the course. You are anonymous and there are NO DUMB questions. If I fail to answer during the course, I will try to answer your question on an FAQ that I will make available at https://github.com/egarbarino/safari_gke
```

```
👍I get it 👎Too much work, I just want to sit and watch
```

## S1.1 Setting up The Google Cloud Shell and GKE

---

I use TMUX to split my terminal session into multiple panes. It comes preinstalled with the Google Cloud Shell, and you can also get it for MacOS and Linux, including Windows Subsystem for Linux (WSL). You can install it by following these instructions: https://github.com/tmux/tmux/wiki/Installing

👍 I use TMUX already. You are preaching to the converted. \
😲 I don't use TMUX but I definitely want to look into it. \
👎 I'm not a terminal hacker. I'd rather open multiple terminal windows.

---

### Access Google Cloud Shell

Browse [https://cloud.google.com/](https://cloud.google.com/) and click on the Google Cloud Shell Icon

Why Google Cloud Shell?
* The gcloud command is installed and pre-authenticated
* kubectl is preinstalled
* TMUX, python, etc.

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

---

In Kubernetes everything is an 'object', a so-called 'API resource', or simply 'resource'. Why should you care? Because the same commands and workflows apply to most objects, such as 'kubectl create', 'kubectl delete', 'kubectl get', 'kubectl explain', and so on. But what is an resource? A nested set of attributes, typically displayed (and edited) using either the JSON or YAML formats.

👍 I have both JSON and YAML for breakfast every day \
😲 I'm shocked. I come from the .ini, .properties, and .xml era. \
👎 Who are Jason and Yamehl?

---

Cd to `safari_gke/getting_started`

### Create Cluster (Course)

```
vi create_cluster.sh
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

---

I will run the 'date' command using Kubernetes in a few moments. As 'silly' as this experiment might be, Kubernetes has to go through multiple hoops to achieve this.

- Download the Alpine container image from Docker Hub
- Wrap the container image in a Pod 
- Find a worker node that has sufficient CPU and RAM to spin up the Pod
- Spin up the Pod (creating the virtual file system specified by the underlying container)
- Execute the 'date' command

👍 No one said distributed computing was easy \
😲 It's a bit over the top, but it is what it is \
👎 I don't need Kubernetes to tell what the time is. I have an Apple Watch Series 8. 


---

### Watch Pod Activity

deleted


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

Generate web requests

```
curl http://127.0.0.1:8080
```

- Attach to nginx using `kubectl attach nginx` (and generate more web requests!)
- Dettach by pressing CTRL+C
- Destroy Pod

### Pod Manifest

Kubectl run can be seen as creating a Pod manifest on the fly

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
kubectl apply -f /tmp/nginx.yaml
```

_end of session_

---

## S1.4 Managing Pod Life Cycle

---

The Pod life cycle is actually rather complex, so I have created a more comprehensive illustration at https://garba.org/article/blog/2018/k8s_pod_lc.pdf 

👍 I got the PDF file. Thanks. \
😲 I got the PDF file but, this is overwhelming! \
👎 The URL is broken. 

---

### Startup Arrguments, PostStart and PreStop Hooks

Create an external disk first

```
gcloud compute disks create my-disk --size=10GB \
    --zone=europe-west2-a
```

Explore 

```
vi life_cycle.yaml
```

Notice `lifecycle.postStart` and `lifecycle.preStop`

Apply manifest

```
kubectl apply -f life_cycle.yaml
```

Check logs

```
kubectl exec -i life-cycle -- cat /data/log.txt`
```

Kill life-cycle and apply again

```
kubectl delete pod/life-cycle
```

_end of section_

---

## S1.5 Implementing Self-Healing Mechanisms

---

The probe life cycle is not that complicated, but it helps to visualise how the various attributes help implemented the intended behaviour. For this, I have another illustration here: https://garba.org/posts/2020/k8s-life-cycle/

👍 I see a bunch of UML Activity diagrams. \
😲 I see lots of boxes and arrows, I'm a bit scared.
👎 The URL is broken. 

---

### Implementing Readiness and Liveness Probes

Explore 

```
vi nginx-self-healing.yaml
```

Apply manfiest

```
kubectl apply -f nginx-self-healing.yaml
```

Notice the readiness probe's failure

Fix the issue

```
kubectl exec pod/nginx-self-healing -- touch /ready.txt
```

Delete index.html

```
kubectl exec nginx-self-healing -- rm /usr/share/nginx/html/index.html
```

Notice Pod being restarted

_Optional_

Use `kubectl describe pod/nginx` for diagnosis

_end of segment_

