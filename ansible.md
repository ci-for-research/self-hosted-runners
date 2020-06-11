
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
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --user ubuntu --private-key=$KEY_PATH -i ./ansible-example/inventory ./ansible-example/hello-playbook.yml -v
```
In this command  you will need to replace $KEY_PATH with the path which you have the ssh-keys. If you are using the Docker image, it will be `/gt/id_rsa_ci_sprint`

The out put of the command will be
```
Using /gt/ansible.cfg as config file

PLAY [This is a hello-world example] *******************************************************************

TASK [Gathering Facts] *********************************************************************************
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host nlesc-ci.demo-nlesc.surf-hosted.nl should use 
/usr/bin/python3, but is using /usr/bin/python for backward compatibility with prior Ansible releases. 
A future Ansible release will default to using the discovered platform python for this host. See 
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more 
information. This feature will be removed in version 2.12. Deprecation warnings can be disabled by 
setting deprecation_warnings=False in ansible.cfg.
ok: [nlesc-ci.demo-nlesc.surf-hosted.nl]

TASK [Print debug message] *****************************************************************************
ok: [nlesc-ci.demo-nlesc.surf-hosted.nl] => 
  msg: Hello, GT!

TASK [list home folder] ********************************************************************************
changed: [nlesc-ci.demo-nlesc.surf-hosted.nl] => changed=true 
  cmd:
  - ls
  - -asl
  - /home/ubuntu
  delta: '0:00:00.002745'
  end: '2020-06-11 18:06:44.915233'
  rc: 0
  start: '2020-06-11 18:06:44.912488'
  stderr: ''
  stderr_lines: <omitted>
  stdout: |-
    total 40
    4 drwxr-xr-x 5 ubuntu ubuntu 4096 Jun 11 18:03 .
    4 drwxr-xr-x 3 root   root   4096 Jun  1 02:44 ..
    4 drwx------ 3 ubuntu ubuntu 4096 Jun 11 17:00 .ansible
    4 -rw------- 1 ubuntu ubuntu    5 Jun 11 18:03 .bash_history
    4 -rw-r--r-- 1 ubuntu ubuntu  220 Jun  1 02:44 .bash_logout
    4 -rw-r--r-- 1 ubuntu ubuntu 3771 Jun  1 02:44 .bashrc
    4 drwx------ 2 ubuntu ubuntu 4096 Jun  1 02:44 .cache
    4 -rw-r--r-- 1 ubuntu ubuntu  807 Jun  1 02:44 .profile
    4 drwx------ 2 ubuntu ubuntu 4096 Jun 11 16:03 .ssh
    0 -rw-r--r-- 1 ubuntu ubuntu    0 Jun  1 02:44 .sudo_as_admin_successful
    4 -rw------- 1 ubuntu ubuntu   62 Jun 11 16:03 .Xauthority
  stdout_lines: <omitted>

PLAY RECAP *********************************************************************************************
nlesc-ci.demo-nlesc.surf-hosted.nl : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

