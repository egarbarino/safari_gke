# safari_gke
Examples for the "Kubernetes On GKE" course on Safari Online

# Initial Setup

## TMUX

Create file `.tmux.conf` and add the following line:

set -g status on

gcloud config set project [PROJECT_ID]

Error
-----
Default change: VPC-native is the default mode during cluster creation for versions greater than 1.21.0-gke.1500. To create advanced routes based clusters, please pass the `--no-enable-ip-alias` flag
Default change: During creation of nodepools or autoscaling configuration changes for cluster versions greater than 1.24.1-gke.800 a default location policy is applied. For Spot and PVM it defaults to ANY, and for all other VM kinds a BALANCED policy is used. To change the default values use the `--location-policy` flag.
Note: Your Pod address range (`--cluster-ipv4-cidr`) can accommodate at most 1008 node(s).
ERROR: (gcloud.container.clusters.create) ResponseError: code=400, message=Failed precondition when calling the ServiceConsumerManager: tenantmanager::185014: Consumer 458749463375 should enable service:container.googleapis.com before generating a service account.
com.google.api.tenant.error.TenantManagerException: Consumer 458749463375 should enable service:container.googleapis.com before generating a service account.
ernesto@cloudshell:~/.../1-getting_started/2-cluster (safari-gke)$ 

