# Troubleshooting ``SSH``

Note: these troubleshooting instructions assume Linux as the operating system on both the client side and the server
side.

## File permissions

The first thing to check is whether your system has the correct permissions on the following files (you can check the
octal representation of the file permission with: ``stat -c %a <filename>``):

```shell
# client-side
chmod go-w $HOME
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/config       # (documentation varies 644, 600, 400)
chmod 600 $HOME/.ssh/id_rsa       # (private keys, rsa and other types)
chmod 644 $HOME/.ssh/id_rsa.pub   # (public keys, rsa and other types)
chmod 600 $HOME/.ssh/known_hosts  # (not documented)

# server side:
chmod 600 <other system''s home dir>/.ssh/authorized_keys
```

## Ownership

All files and directories under `~/.ssh`, as well as `~/.ssh` itself, should be owned by the user.

```shell
chown -R $(id -u):$(id -g) ~/.ssh
```

## Verbosity

Increase ``ssh``'s verbosity using the ``-vvvv`` option (more ``v``'s means higher verbosity), e.g.

```shell
ssh -vvv username@hostname
```

Another useful option is to ask ``ssh`` for a list of its configuration options and their values with the ``-G`` option,
e.g.

```shell
ssh -G anyhost
ssh -G user@some.system.com
```

Sometimes, a connection cannot be set up because of a configuration problem on the server side. If you have access to
the server through another way, running

```shell
sshd -T
```

might help track the problem down. Note that the results may be user-dependent, for example the result may be different
for ``root`` or for a user.

## Configuration settings

1. client-side, global user configuration: ``/etc/ssh/ssh_config``
1. client-side, local user configuration ``$HOME/.ssh/config``
1. server-side, global system configuration for ssh server daemon ``/etc/ssh/sshd_config``

## Related to `known_hosts` file


1. host name hashed or not ``hashKnownHosts``
1. strict host key checking ``strictHostKeyChecking``
1. removing a given host's key goes like this

    ```
    ssh-keygen -R [localhost]:10022
    ```

## Encrypted ``/home``

Using encryption on your home drive may negatively affect things: <https://help.ubuntu.com/community/SSH/OpenSSH/Keys>
