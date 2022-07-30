## Implementing Self-Healing Mechanisms

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

