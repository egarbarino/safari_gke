# S4 Further Controller Types

## S4.1 Running Server-Wide Services using DaemonSets

---

If you are a Linux user, how would do you define a 'daemon', as opposed to a simple program running in the background? (no wrong answer)

👍 A daemon typically performs services for one or more other programs \
😲 A daemon is normally started during startup time \
👎 I'm afraid of ghosts and day-mons. Dee-mons? Not scary.

---

Cd to folder `further`:

Set up monitoring in different panes

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

* Pane 1: `watch -n 1 -w kubectl get pod -o wide` (note -o wide)
* Pane 2: `watch -n 1 kubectl get daemonset`
* Pane 3.left: `watch -n 1 kubectl get deployment`
* Pane 3.right: Leave empty for now
* Pane 4: `cd ~/safari_gke/further`

### TCP-Based Daemons

Explore and apply

```
vi logDaemon.yaml
kubectl apply -f logDaemon.yaml
```

Note that there is exactly one Pod per Node

Explore and apply client

(!) Note use of Downward API for getting `HOST_IP`

```
vi logDaemonClient.yaml
kubectl apply -f logDaemonClient.yaml
```

Pane 3.right: Check logs per a given node

```
kubectl exec logd-XXXXXXXX -- cat /var/node_log
```

### File-Based Daemons

Delete everything

```
kubectl delete all --all
```

Explore and apply

```
vi logCompressor.yaml
kubectl apply -f logCompressor.yaml
```

Pane 3.right:

```
kubectl exec logcd-XXXXXXX -- find /var/log -name "*.gz"
```

Explore client and apply

```
vi logCompressorClient.yaml
kubectl apply -f logCompressorClient.yaml
kubectl exec logcd-XXXXXX -- tar -tf /var/log/all-logs-XXXXXXX.tar.gz
```

_end of section_

---

## S4.2 Instrument Stateful Applications using StatefulSets

---

Have you ever installed a database management system all by yourself?

👍 Yes, a SQL database \
😲 Yes, a noSQL database \
👎 Haven't you heard of Google Spanner? I prefer managed databases

---

Delete everything

```
kubectl delete all --all
```

Pane 3.right: `watch -n 1 kubectl get statefulset`

### Primitive Key/Value Store

Explore and Apply

```
vi server.py
cd wip
vi configmap.sh
vi server.yaml
./configmap.sh
kubectl apply -f server.yaml
```

Panel 3.left:

```
kubectl port-forward server-0 1080:80
```

Experiment saving and loading keys

```
curl http://localhost:1080/save/title/Sapiens
curl http://localhost:1080/load/title
curl http://localhost:1080/save/author/Yuval
curl http://localhost:1080/load/author
curl http://localhost:1080/allKeys
```

Connect to another server and see that no keys are stored

### Sequential Pod Creation and Termination

(!) Destructive

Increment and then Decrement

```
kubectl scale statefulset/server --replicas=5
kubectl scale statefulset/server --replicas=3
```

### Stable Network Identity and Headless Service


Panel 3.left:

```
watch -n 1 -w kubectl get service
```

* No loadbalancer, just a DNS entry
* Note on service.yaml that ClusterIP is set to None

```
vi service.yaml
kubectl apply -f service.yaml
kubectl run --image=alpine --restart=Never --rm -i test -- nslookup -type=srv server | head -n 7
```

### Client for Headless Service

Pane 2: `kubectl logs -f client` (do not press ENTER yet)

(!) Concept of sharding using moduluo arithmetic

```
python3
ord('a') % 3
...
```

Explore and run smart client

```
cd ~/safari_gke/further
vi client.py
vi client.yaml
vi wip/configmap2.sh
cd wip
./configmap2.sh
kubectl apply -f ../client.yaml
```

Explore logs

```
kubectl logs client | head
```

Delete one random server Pod

```
kubectl delete pod/server-1
```

### Disk Persistence using Persistent Volume Claims

Delete everything

```
kubectl delete all --all
```

Explore and apply

Pane 3.left: `watch -n 1 -w kubectl get pvc` (or pv, try!)
Pane 3.right: `watch -n 1 "gcloud compute disks list | grep NAME"`

Note preStart and postStop hooks on server.yaml

```
cd ~/safari_gke/further
vi server.py          # Note return of 503 code on shutting_down
vi server-disk.yaml   # Note preStart/postStart hooks and Disk Volume  
vi configmap.sh
./configmap.sh
kubectl apply -f server-disk.yaml
```

Panel 2: `kubectl logs -f client` (do not press Enter)

```
kubectl apply -f client.yaml
```

Chaos engineering:

```
kubectl delete pod/server-2
kubectl delete statefulset/server 
kubectl apply -f server-disk.yaml
```

_end of segment_

---


