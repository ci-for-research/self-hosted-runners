# Setting up a CI server for a GitHub Action runner with Docker from Linux Ubuntu

After following this guide, you'll have a simple GitHub action workflow on a GitHub repository of your choice. When new commits are made to your repository, the workflow delegates work to a server which runs in a [Docker](https://www.docker.com/) container.

This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever
machine will run the tests. This document describes the case where the server is a Docker container running on your own machine.

For guides on how to configure other features in addition to just the runner, go [here](/README.md).

## Prerequisites

1. Install Docker: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)
2. Follow post-installation steps [https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) to manage docker as a non-root user

### Testing your Docker setup

Refence: [https://docs.docker.com/docker-for-windows/#test-your-installation](https://docs.docker.com/docker-for-windows/#test-your-installation)

1. Open a terminal window

2. Run ``docker --version`` to ensure that you have a supported version of Docker:

```shell
> docker --version

Docker version 19.03.11-ce, build 42e35e61f3
```

3. Pull the hello-world image from Docker Hub and run a container:

```shell
> docker run hello-world

Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete
Digest: sha256:d58e752213a51785838f9eed2b7a498ffa1cb3aa7f946dda11af39286c3db9a9
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

4. List the hello-world image that was downloaded from Docker Hub:

```shell
> docker image ls

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              bf756fb1ae65        6 months ago        13.3kB
```

5. List the hello-world container (that exited after displaying “Hello from Docker!”):

```shell
> docker container ls --all

CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS                          PORTS               NAMES
1d624a063f22        hello-world         "/hello"            About a minute ago   Exited (0) About a minute ago                       flamboyant_ramanujan
```

## Server side configuration

### Build image

Now we are ready to build our Docker image. The following command will use [Dockerfile](Dockerfile) to build the image. It will create a system user, install necessary system packages and dependencies for the runner.

```shell
docker build \
    --tag github-actions-runner \
    .
```

The Docker image will create a user called ``tester`` with a password ``password``. If you want to change the default username and the password, you will need to adjust `<username>` and `<user password>` for the user which will be added to the Docker image.

```shell
docker build \
    --tag github-actions-runner \
    --build-arg DOCKER_USER="<username>" \
    --build-arg DOCKER_PASS="<user password>" \
    .
```

## Client side configuration

### Generate an OAuth token

We're almost ready to use our Docker image to set up a GitHub Runner, but first we need to
generate an OAuth token, as follows:

1. Go to [https://github.com/settings/tokens](https://github.com/settings/tokens) and click the ``Generate new token`` button.
2. Provide your GitHub password when prompted
3. Fill in a description for the token, for example _GitHub runner for github.com/&lt;your organization&gt;/&lt;your repository&gt;_
4. Enable the ``repo`` scope and all of its checkboxes, like so:

    ![Token permissions](/images/token_permissions.png)

5. Click ``Generate`` at the bottom. Make sure to copy its value because we'll need it in the next step

### Run the server

#### Daemon mode

The command below will start the Docker container in daemon mode. The Docker container will run in the background and the terminal will be available. To stop the running container you need to run the ``stop`` command, which is explained in the [Cleanup](#cleanup) section.

```shell
docker run -d --restart always --name github-actions-runner \
    --env PERSONAL_ACCESS_TOKEN=<Github OAuth token> \
    --env RUNNER_NAME=<runner name to appear on Github> \
    --env RUNNER_WORKDIR=/tmp/actions-runner-repo \
    --env GITHUB_ORG=<organization or username> \
    --env GITHUB_REPO=<name of the repository> \
    github-actions-runner:latest
```

If you stop the running container, the Github actions runner will also stop.

To stop the running Docker container:

```shell
docker container stop github-actions-runner
```

To start the Docker container again:

```shell
docker container start github-actions-runner
```

#### Temporary mode

The command below will run the docker image and set up the runner. When user presses `CTRL+C`, it automatically removes the runner from GitHub and removes the Docker container as well.

```shell
docker run --rm --name github-actions-runner \
    --env PERSONAL_ACCESS_TOKEN=<personal access token> \
    --env RUNNER_NAME=<runner name to appear on Github> \
    --env RUNNER_WORKDIR=/tmp/actions-runner-repo \
    --env GITHUB_ORG=<organization or username> \
    --env GITHUB_REPO=<name of the repository> \
    github-actions-runner:latest
```

**Warning:** If you use ``--rm`` argument, Docker will remove the container and you will loose your changes. However, this can be useful for testing purposes.

#### Adding a CI workflow on Github

If you now go to GitHub [https://github.com/&lt;your organization&gt;/&lt;your repository&gt;/settings/actions](https://github.com/%3Cyour%20organization%3E/%3Cyour%20repository%3E/settings/actions),
you should see a self-hosted runner with status "Idle":

![Self hosted runner status is Idle](/images/github-self-hosted-runners-status-idle.png)

Add the following simple workflow as ``.github/workflows/self_hosted_ci.yml`` in your repository:

```yaml
name: Self-hosted CI example
on: [push, pull_request]
jobs:
  test:
    name: test
    runs-on: self-hosted
    steps:
      - name: Show directory listing
        shell: bash -l {0}
        run: |
          ls -la
```

Now try making a change to one of the files in your repository to see if you can trigger running the simple workflow
on your self-hosted server. If successful, the status will change to "Active" while the workflow is running. You can
get an overview of previous GitHub actions by navigating to [https://github.com/&lt;your organization&gt;/&lt;your repository&gt;/actions](https://github.com/%3Cyour%20organization%3E/%3Cyour%20repository%3E/actions).


### Cleanup

To stop the running Docker container:

```shell
docker container stop github-actions-runner
```

To start the running Docker container:

```shell
docker container start github-actions-runner
```

To remove a Docker container

```shell
docker container rm github-actions-runner
```

To remove a Docker image

```shell
docker image rm github-actions-runner
```

### Extras

#### Get Docker container details

Use `docker inspect` to display details of the container
```shell
> docker inspect  github-actions-runner

[
    {
        "Id": "4ff7f37a894e351dc1def53c76959ac30c09083347ada25fcb55dc6687f8d295",
        "Created": "2020-07-02T18:29:53.106234584Z",
        "Path": "/bin/sh",
...
```

You can use the command below to only find out the IP address of the container
```shell
> docker inspect --format '{{ .NetworkSettings.IPAddress }}' github-actions-runner

172.17.0.2
```

#### Accessing Docker container

If you need access to a shell on the running Docker container:

```shell
docker exec -ti github-actions-runner /bin/bash
```

### What's next

Find instructions for provisioning additional functionality [here](../README.md).
