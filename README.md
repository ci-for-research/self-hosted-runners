| Five recommendations for fair software from [fair-software.nl](https://fair-software.nl) | Badges |
| --- | --- |
| 1. Code repository | [![GitHub badge](https://img.shields.io/badge/github-repo-000.svg?logo=github&labelColor=gray&color=blue)](https://github.com/NLESC-JCER/linux_actions_runner/) |
| 2. License | [![License badge](https://img.shields.io/github/license/NLESC-JCER/linux_actions_runner)](https://github.com/NLESC-JCER/linux_actions_runner/) |
| 3. Community registry | Galaxy badge | 
| 4. Enable citation | [![DOI](https://zenodo.org/badge/DOI/10.0000/FIXME.svg)](https://doi.org/10.0000/FIXME) |
| 5. Checklist | ? |

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
