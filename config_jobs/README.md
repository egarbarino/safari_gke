# S3 Configuration and Jobs

Segment TMUX Setup

```
|------------------|
|        1         |
|------------------|
|        2         |
|------------------|
| 3.left | 3.right | 
|------------------|
|        4         |
--------------------
```

Pane 1

```
watch -n 1 kubectl get pod
```

Pane 2

```
watch -n 1 kubectl get configmap
```

Pane 3.left: Leave empty for now

Pane 3.right: Leave empty for now

Pane 4

```
cd ~/safari_gke/config_jobs/
```

## S3.1 Externalizing Configuration using ConfigMap


### Example of Hard Coded Configuration

```
vi podHardCodedEnv.yaml
```

```
kubectl apply -f podHardCodedEnv.yaml
```

```
kubectl logs pod/my-pod
```

### Define ConfigMap Separately


```
vi simpleconfigmap.yaml
```

```
kubectl apply -f simpleconfigmap.yaml
```

```
kubectl describe configmap/data-sources
```

Note there is an imperative form: `kubectl create configmap --help`

### Reference External Configuration from Pod

Delete Old Pod

```
kubectl delete pod/my-pod
```

Explore


```
vi podWithConfigMapReference.yaml
```

Apply

```
kubectl apply -f podWithConfigMapReference.yaml
```

Check logs

```
kubectl logs pod/my-pod
```

### Referencing Specific Fields

Explore:

```
vi podManifest.yaml
```

### Live Configuration Changes using Virtual File System

Pane 3.right: Delete everything

```
kubectl delete all --all
```

Explore

```
vi configMapLongText.yaml
```

Apply

```
kubectl apply -f configMapLongText.yaml
```

Explore `volume`, `volumeMounts`

```
vi podManifestVolume.yaml
```

Apply 

```
kubectl apply -f podManifestVolume.yaml
```

Pane 3.left:

```
kubectl logs -f pod/my-pod
```

Explore 

```
vi configMapLongText_changed.yaml
```

Apply

```
kubectl apply -f configMapLongText_changed.yaml
```

_end of section_

---

## S3.2 Protecting Credentials using Secrets

Pane 3.right: Delete everything

```
kubectl delete all --all
```

Set up secrets monitoring 

Pane 2:

```
watch -n 1 kubectl get secret
```

Pane 3.left

```
watch -n 1 kubectl get secret/my-secrets -o yaml
```

### Imperative Form

```
kubectl create secret generic my-secrets \
    --from-literal=mysql_user=ernie \
    --from-literal=mysql_pass=HushHush
```

### Declarative Form

```
kubectl delete secret/my-secrets
```

```
echo -n ernie | base64
```

```
echo -n HushHush | base64
```

```
vi secrets/secretManifest.yaml
```

```
kubectl apply -f secrets/secretManifest.yaml
```

### Injecting Secrets

```
vi secrets/podManifestFromEnv.yaml
```

```
kubectl apply -f secrets/podManifestFromEnv.yaml
```

```
kubectl logs pod/my-pod
```

### Further Use Cases (Student Only)

* Select specific variables: `secrets/podManifesSelectedEnvs.yaml`
* Mount secrets as volume: `secrets/podManifestVolume.yaml`

### Docker Secrets (Student Only)

* Check out `../getting_started/docker_hub_fix.sh`
* Note `spec.imagePullSecrets` on `secrets-docker/podFromPrivate.yaml`

_end of section_

---

## S3.3 Implementing Batch Processes using Jobs


Pane 4

```
kubectl delete all --all
```

Pane 2

```
watch -n 1 kubectl get job
```

Pane 3.right

```
kubectl get -w job
```

### Single Batch Process

```
kubectl create job two-times --image=alpine \
    -- sh -c \
    "for i in \$(seq 10);do echo \$((\$i*2));done"
```

Check out results and note label selector:

```
kubectl logs -l job-name=two-times
```

Note declarative version:

```
vi two-times.yaml
```

Note that job **won't go away** unless deleted!

```
kubectl delete job/two-times
```

### Completion Count-Based Batch Process

Pane 3.right:

```
while true; do kubectl describe job/even-seconds \
    | grep Statuses ; sleep 1 ; done
```

Explore:

```
vi even-seconds.yaml
```

Note:

* `spec.completions` (need to succeed 6 times)
* `spec.parallelism` (may run two pods in parallel to achieve the job)
* Script which randomly produces SUCCESS or FAILURE

Apply

```
kubectl apply -f even-seconds.yaml
```

Note activity across all panes

Explore logs

```
kubectl logs -l job-name=even-seconds 
```

_end of section_

### Externally Coordinated Batch Process


Pane 3.left:

```
kubectl delete job --all
```

Pane 3.right: stop and clear

Explore queue and **note** `--expose`:

```
vi startQueue.sh
```

```
./startQueue.sh
```

Test queue

```
kubectl run test --rm -ti --image=alpine \
    --restart=Never -- sh
```

Inside Pod: Try a few times and then exit

```
nc -w 1 queue 1080
```

Explore 

```
vi multiplier.yaml
```

Note:

* The attribute `spec.completion` is left empty
* The attribute `spec.parallelism` is set to 3


Restart Queue by running again:

```
./startQueue.sh
```

Apply Multiplier

```
kubectl apply -f multiplier.yaml
```

Explore results and note that `--tail=-1` is to override the label selector's limit

```
kubectl logs -l job-name=multiplier --tail=-1 | wc
```

```
kubectl logs -l job-name=multiplier --tail=-1 | sort -g
```

_end of section_

---

## S3.4 Scheduling Recurring Tasks Using CronJobs


Pane 3.right: Delete jobs

```
kubectl delete job --all
```

Pane 3.left

```
watch -n 1 kubectl get cronjob
```

### Understand crontab file format

* Use an utility like https://crontab.guru/
* For example: `*/5 * * * *` is every five minutes

### Run Simple Cron Job

Note imperative version using `kubectl create cronjob --help`

```
vi simple.yaml
```

```
kubectl apply -f simple.yaml
```

Wait for it to run and then get logs:

```
kubectl logs simple-XXXXXXXXXX
```


### Suspending and Resuming Cron Jobs

Suspend:

```
kubectl patch cronjob/simple \
    --patch '{"spec" : { "suspend" : true }}'
```

Unsuspend:

```
kubectl patch cronjob/simple \
    --patch '{"spec" : { "suspend" : false }}'
```

_end of segment_








