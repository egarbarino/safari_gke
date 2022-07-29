## Getting Started With GKE

## Initial Setup

### Google Cloud Platform

Fundamentals

1. Create an account at [https://cloud.google.com/](https://cloud.google.com/)
2. Set up billing (e.g., enter your credit card)
3. Create a project (we use 'safari-gke' in our examples)
4. Associate billing with the project

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

### How To Use Code Examples

The examples are meant to followed in a _relative_ sequential
fashion, but many of them suggest the set up of 'watchers' or steady
monitoring scripts in different windows/panels/panes/tabs/etc. Others,
instead may require user interaction.

In addition, the comments may suggest further experimentation beyond
the directly executable scripts.


