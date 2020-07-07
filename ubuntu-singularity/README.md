# Setting up a CI server for a GitHub Action runner Singularity from Linux Ubuntu

After following this guide, you'll have a simple GitHub action workflow on a GitHub repository of your choice. When new commits are made to your repository, the workflow delegates work to a server which runs in a [Singlularity](https://sylabs.io/singularity/) container. You can use this Singularity container to on a HPC cluster.

This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever
machine will run the tests. This document describes the case where the server is a Singularity container running on your own machine.

For guides on how to configure other features in addition to just the runner, go [here](/README.md).

## Prerequisites

1. Install Singularity: https://sylabs.io/guides/3.5/user-guide/quick_start.html#quick-installation-steps

2. Follow a [short tutorial](https://sylabs.io/guides/3.5/user-guide/quick_start.html#overview-of-the-singularity-interface) (Optional)

### Testing your Singularity setup

Check Singularity version
```shell
> singularity version

3.5.3
```

Pull an example image

```shell
singularity pull library://sylabsed/examples/lolcow
```

Start a shell in the Singlarity container

```shell
singularity shell lolcow_latest.sif
```

Sun some test commands

```shell
Singularity> id

uid=1000(fdiblen) gid=985(users) groups=985(users),98(power),108(vboxusers),972(docker),988(storage),998(wheel)

Singularity> hostname

archlinux
```

## Server side configuration

### Build image

Now we are ready to build our Singularity image. The following command will use [Definition file](github-actions-runner-singularity.def) to build the image. It will create a system install necessary system packages and dependencies for the runner. In order to create a Singularity image, you will need root permission (or sudo) on your system.

```shell
sudo singularity build github-actions-runner-singularity.sif github-actions-runner-singularity.def
```

This command will generate ``github-actions-runner-singularity.sif`` image.
