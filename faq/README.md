# FAQ

## I don't like using the Google Cloud Shell. Can I use my favourite OS and shell?

Yes. There's nothing special about the Google Cloud Shell; it is just, for all intents and purposes, a Linux VM. It is just convenient for the course because it can be used directly on a web browser and comes with the likes of Python and TMUX preinstalled. Here below, I provide a general workflow for setting up the same environment:

### Download the Google Cloud CLI for your OS:

https://cloud.google.com/sdk/docs/install

If Python is missing, you'll be given further steps as to what to do next.

### Initialise The Google Cloud Shell

```
$ gcloud init
```

### When Prompted, Choose to Log In

```
To continue, you must log in. Would you like to log in (Y/n)? Y
```

After answering this questions, you'll be redirected to a web page to enter your credentials.
Once you are succesfully authenticated, you'll be offered the options of selecting defaults. For the course (but you might have defined different options), these are:

Project (If you don't have a default project, you can create one using the web console)

```
Pick cloud project to use: 
 [1] safari-gke
```

Region (London)

```
Which Google Compute Engine zone would you like to use as project default?
 [25] europe-west2-a
```

### Install Kubectl

```
$ gcloud components install kubectl
$ gcloud version 
```

## I saw that you use TMUX to switch between different shell sessions. Do I need it?

TMUX is not necessary for the course. You can open multiple shell windows, or use tabs as well. TMUX allows running multiple shells within the cursor environment, so that one is not at the mercy of the shell's features (or lack thereof). If you are still curious about TMUX, you can get it from here:

https://github.com/tmux/tmux/wiki/Installing






