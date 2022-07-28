1. Open a Google Account
2. Set up Billing (e.g. enter your credit card)
3. Create a project called 'safari-gke'
4. Associate billing with the project
### Init

Source: [1-getting_started/1-init/init.sh](1-getting_started/1-init/init.sh)

``` bash
#/bin/sh
# Set your project
gcloud config set project safari-gke

# Set your preferred compute zone
gcloud config set compute/zone europe-west2-a

# Enable GKE service
# This won't work unless Billing is enabled and associated to your project
# (for example, safari-gke)
gcloud services enable container.googleapis.com

```

### Create Cluster

Source: [1-getting_started/2-cluster/create_cluster.sh](1-getting_started/2-cluster/create_cluster.sh)

``` bash
#/bin/sh
gcloud container clusters create my-cluster \
   --zone europe-west2-a
#    --enable-basic-auth 
#    --quiet \
#    --async \
#     --issue-client-certificate \
```

