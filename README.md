| Five recommendations for fair software from [fair-software.nl](https://fair-software.nl) | Badges |
| --- | --- |
| 1. Code repository | [![GitHub badge](https://img.shields.io/badge/github-repo-000.svg?logo=github&labelColor=gray&color=blue)](https://github.com/ci-for-science/self-hosted-runners/) |
| 2. License | [![License badge](https://img.shields.io/github/license/ci-for-science/self-hosted-runners)](https://github.com/ci-for-science/self-hosted-runners/) |
| 3. Community registry | [![Ansible Galaxy badge](https://img.shields.io/badge/galaxy-fixme.fixme-660198.svg)](https://galaxy.ansible.com/fixme/fixme) |
| 4. Enable citation | [![DOI](https://zenodo.org/badge/DOI/10.0000/FIXME.svg)](https://doi.org/10.0000/FIXME) |
| 5. Checklist | ? |

This repository explains how to set up a server for running continuous integration tests on other hardware than what
GitHub provides. This can be useful when the code you want to test has special requirements, for example if

- it needs a GPU to run
- it needs multiple nodes
- testing requires data that needs to stay on-premises for privacy reasons or legal reasons
- testing requires data that is too big to move
- testing requires specific software

This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever
machine runs the tests. For either side, we'll explain what configuration needs to be done. For people who just want to
try out the instructions but don't have access to remote hardware, we included a few alternatives for running the server
locally as well, through the use of virtualization (with VirtualBox) and containerization (with Docker).

For the client, we included instructions for Linux Ubuntu, Mac, and Windows; the server-side instructions all assume
Linux Ubuntu.

| client OS | server hardware | Link |
| --- | --- | --- |
| Linux Ubuntu | remote machine at [SURF HPC Cloud] | [link](ubuntu-surf-hpc-cloud/README.md) |
| Linux Ubuntu | local machine via Docker           | [link](ubuntu-docker/README.md) |
| Linux Ubuntu | local machine via VirtualBox       | [link](ubuntu-virtualbox/README.md) |
| Linux Ubuntu | local machine via Vagrant          | [link](ubuntu-vagrant/README.md) |
| Mac          | remote machine at [SURF HPC Cloud] | - |
| Mac          | local machine via Docker           | - |
| Mac          | local machine via VirtualBox       | - |
| Windows      | remote machine at [SURF HPC Cloud] | - |
| Windows      | local machine via Docker           | - |
| Windows      | local machine via VirtualBox       | - |

<br/><br/> 

**A warning from GitHub for self-hosted runners in combination with public repositories is shown [here](https://help.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners#self-hosted-runner-security-with-public-repositories). Please take this seriously. It basically means that the combination of a self-hosted runner and a public GitHub repository is unsafe. However, there was a [recent discussion](https://github.com/actions/runner/issues/494) indicating that GitHub may add features to make this combination safe in the near future.**

[SURF HPC Cloud]: https://userinfo.surfsara.nl/systems/hpc-cloud

   
