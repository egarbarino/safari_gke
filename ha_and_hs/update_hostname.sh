#!/bin/sh
# Updates homepage of every running Pod to the hostname
pods=$(kubectl get pods -o=jsonpath={.items[*].metadata.name})
for pod in $pods; \
    do kubectl exec -ti $pod \
           -- bash -c "echo \$HOSTNAME - Nginx \$NGINX_VERSION> \
           /usr/share/nginx/html/index.html"; \
    done
