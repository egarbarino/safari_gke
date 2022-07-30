## Setting up The Google Cloud Shell and GKE

[Source](getting_started/initialization)

Learning objectives:

- Learn how to access the Google Cloud Shell
- Learn how to set the project id and compute zone
- Learn how to enable access to Kubernetes services

 Setting up The Google Cloud Shell and GKE

### Google Cloud Platform

Fundamentals

1. Create an account at [https://cloud.google.com/](https://cloud.google.com/)
2. Set up billing (e.g., enter your credit card)
3. Create a project (we use 'safari-gke' in our examples)
4. Associate billing with the project

### Google Cloud Shell

Tmux (Optional)

Create file `.tmux.conf` and add the below line to have
the status bar visible at all times:

```
set -g status on
```

Project (Optional)

Add the below line to the end of `.bashrc` 
in your home directory to avoid setting the 
project for every session:

```
gcloud config set project safari-gke
```

