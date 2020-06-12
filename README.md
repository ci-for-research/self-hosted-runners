| Five recommendations for fair software from [fair-software.nl](https://fair-software.nl) | Badges |
| --- | --- |
| 1. Code repository | [![GitHub badge](https://img.shields.io/badge/github-repo-000.svg?logo=github&labelColor=gray&color=blue)](https://github.com/NLESC-JCER/linux_actions_runner/) |
| 2. License | [![License badge](https://img.shields.io/github/license/NLESC-JCER/linux_actions_runner)](https://github.com/NLESC-JCER/linux_actions_runner/) |
| 3. Community registry | [![Ansible Galaxy badge](https://img.shields.io/badge/galaxy-fixme.fixme-660198.svg)](https://galaxy.ansible.com/fixme/fixme) | 
| 4. Enable citation | [![DOI](https://zenodo.org/badge/DOI/10.0000/FIXME.svg)](https://doi.org/10.0000/FIXME) |
| 5. Checklist | ? |

This repository explains how to set up a server for running continuous integration tests on other hardware than what
GitHub provides. This can be useful when the code you want to test has special requirements, for example if

- it needs a GPU to run
- it needs multiple nodes
- the testing requires data that needs to stay on-premises for privacy reasons or legal reasons

This guide distinguishes between the _client_ and the _server_; the client is your own machine; the server is whichever
machine runs the tests. For either side, we'll explain what configuration needs to be done. For people who just want to
try out the instructions but don't have access to remote hardware, we included a few alternatives for running the server
locally as well, through the use of virtualization (with VirtualBox) and containerization (with Docker). 

For the client, we included instructions for Linux Ubuntu, Mac, and Windows; the server-side instructions all assume
Linux Ubuntu.

| client OS | server hardware | Link |
| --- | --- | --- |
| Linux Ubuntu | remote machine at [SURF HPC Cloud] | [link](linux-ubuntu-client-to-remote-machine-at-surf-hpc-cloud/README.md) |
| Linux Ubuntu | local machine via Docker           | [link](linux-ubuntu-client-to-local-machine-via-docker/README.md) |
| Linux Ubuntu | local machine via VirtualBox       | [link](linux-ubuntu-client-to-local-machine-via-virtualbox/README.md) |
| Mac          | remote machine at [SURF HPC Cloud] | - |
| Mac          | local machine via Docker           | - |
| Mac          | local machine via VirtualBox       | - |
| Windows      | remote machine at [SURF HPC Cloud] | - |
| Windows      | local machine via Docker           | - |
| Windows      | local machine via VirtualBox       | - |


[SURF HPC Cloud]: https://userinfo.surfsara.nl/systems/hpc-cloud


--- 
old readme text:

# What is this repository for?
This repository contains a recipe to use the [GitHub Actions infrastucture](https://docs.gitlab.com/ee/ci/README.html) with your own infrastucture. The recipe installs and configures a [GitHub action runner](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/hosting-your-own-runners) using [ansible](https://www.ansible.com/).

## Step to install and register a Github Actions self-hosted runner
This recipe try to automate the [Adding sef-hosted runner](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/adding-self-hosted-runners) instructions. To install your Linux runner
you will need to:

1. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) in your computer.
2. Clone [this repo](https://github.com/NLESC-JCER/gitlab_runner).
3. Edit the [inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html) file with the address of the server(s) where you want to install the runner.
4. Edit the [playbook](https://docs.ansible.com/ansible/latest/user_guide/playbooks.html) file with the `remote_user` name for the hosts.
5. Make sure that you can ssh to your server(s).
6. Install the runner with the following command:
   ``ansible-playbook -i inventory playbook.yml``

## Note:
*The script will ask you for a token for your new runner, you can find such token in the configuration of the CI/CD at the mirror repository that Github automatically creates for you. See the [configuration instructions](https://docs.gitlab.com/ee/ci/runners/#registering-a-specific-runner-with-a-project-registration-token).*

### Supported OS
Currently the recipe only works for **Ubuntu**.

