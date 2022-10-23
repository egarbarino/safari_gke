# S1 Getting Started With GKE

## Pre-Course Set Up

### Instructor Only

Main Browser

* Tab 1: https://console.cloud.google.com
* Tab 2: https://shell.cloud.google.com/?show=terminal
* Tab 3: https://crontab.guru/
* Tab 4: https://garba.org/posts/2018/k8s_pod_lc/
* Tab 5: https://garba.org/posts/2020/k8s-life-cycle/

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
gcloud container clusters create my-cluster \
    --zone europe-west2-a \
    --project safari-gke
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
👍I get it 👎 Too much work, I just want to sit and watch
```

## S1.1 Setting up The Google Cloud Shell and GKE

```
I use TMUX to split my terminal session into multiple panes. It comes preinstalled with the Google Cloud Shell, and you can also get it for MacOS and Linux, including Windows Subsystem for Linux (WSL). You can install it by following these instructions: https://github.com/tmux/tmux/wiki/Installing
```

```
👍 I use TMUX already. You are preaching to the converted. 😲 I don't use TMUX but I definitely want to look into it 👎 I'm not a terminal hacker. I'd rather open multiple terminal windows.
```

### Access Google Cloud Shell

Browse [https://cloud.google.com/](https://cloud.google.com/) and click on the Google Cloud Shell Icon

Why Google Cloud Shell?
* The gcloud command is installed and pre-authenticated
* kubectl is preinstalled
* TMUX, python, etc.
* Closer to IaC

### Set up project

```
gcloud config set project safari-gke
```

You may add it to `~/.bashrc`

```
tail ~/.bashrc
```

### Enable Container Service

```
gcloud services enable container.googleapis.com
```

_end of section_

---


## S1.2 Creating and Destroying Kubernetes Clusters



### Cluster Creation and Deletion

Step 1 - Switch to Window 0 (and explore `gcloud container clusters ...`

Step 2 - Switch to Window 1 

Step 3 - Understand (but do not run!) cluster deletion

```
gcloud container clusters delete my-cluster \
	--async \
	--quiet \
	--zone europe-west2-a
```

### Introduce Nodes and Objects

Everything is an object

```
kubectl get node
```

```
kubectl get node/XXX -o yaml
```

```
kubectl explain node
```

```
kubectl delete node/XXX
```

_end of section_

---

## S1.3 Launching Docker Containers Using Pods


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

Delete it!

```
kubectl delete pod/my-pod
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

Pane 3.left: Watch logs

```
kubectl logs -f nginx
```

Pane 3.right: Establish port-forwarding

```
kubectl port-forward nginx 8080:80
```

Generate web requests

```
curl http://127.0.0.1:8080
```

Further experiments:

- Attach to nginx using `kubectl attach nginx` (and generate more web requests!)
- Detach by pressing CTRL+C
- Destroy Pod

### Pod Manifest

Pane 3.left: Stop and clear

Pane 3.right: Stop and clear

Pane 4

```
kubectl delete pod/nginx
```

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

Apply

```
kubectl apply -f /tmp/nginx.yaml
```

_end of session_

---

## S1.4 Managing Pod Life Cycle


### Startup Arguments, PostStart and PreStop Hooks

Pane 3.left:

```
watch -n 1 "gcloud compute disks list | grep NAME"
```

Pane 4: Create an external disk first

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
kubectl exec -i life-cycle -- cat /data/log.txt
```

Kill life-cycle and apply again

```
kubectl delete pod/life-cycle
```

_end of section_

---

## S1.5 Implementing Self-Healing Mechanisms


### Implementing Readiness and Liveness Probes

Explore 

```
vi nginx-self-healing.yaml
```

Apply manifest

```
kubectl apply -f nginx-self-healing.yaml
```

Notice the readiness probe's failure and fix the issue

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

