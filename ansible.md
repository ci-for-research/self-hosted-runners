
# Instructions to test Ansible with CI server

## Step 1. Get SSH-Keys

Download the ssh-keys as decribed in [#23](https://github.com/NLESC-JCER/linux_actions_runner/issues/23) and put it in the current folder.

## Step 2. Install Ansible

### Option 1: Install ansible
https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

### Option 2: Use docker image to run Ansible

Download the ssh-keys as decribed in [#23](https://github.com/NLESC-JCER/linux_actions_runner/issues/23) and put it in the current folder.

Pull ansible image:

```shell
docker pull ansible/ansible-runner
```

Get a shell using the command below

```shell
docker run --rm -ti -v ${PWD}:/gt ansible/ansible-runner /bin/bash
```

once you get a shell prompt
```shell
cd /gt
```

## Step 3. Run the playbook

Finally, use the command below to run ansible:

```shell
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --user ubuntu --private-key=$KEY_PATH -i ./ansible-example/inventory ./ansible-example/hello-playbook.yml
```
In this command  you will need to replace $KEY_PATH with the path which you have the ssh-keys. If you are using the Docker image, it will be `/gt/id_rsa_ci_sprint`
