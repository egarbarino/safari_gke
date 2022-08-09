#!/bin/sh
# Updates homepage of every running Pod to the hostname
for pod in $pods; \
    do kubectl exec -ti $pod \
           -- bash -c "echo \$HOSTNAME > \
           /usr/share/nginx/html/index.html"; \
    done