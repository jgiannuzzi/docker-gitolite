# Docker image for Gitolite

This image allows you to run a git server in a container with OpenSSH and [Gitolite](https://github.com/sitaramc/gitolite#readme).

Based on Alpine Linux.

# Environment variables

* CONFD_CMDLINE: confd command line (default: `confd -onetime -backend env`)
* SSH_KEY: Public key of gitolite admin (first run only)
* SSH_KEY_NAME: Name of gitolite admin (first run only)

## Confd environment variables

These must be set at first run or when overriding confd command line.

* AUTHKEYGIT_LDAP_ATTRS
* AUTHKEYGIT_LDAP_DNGROUP
* AUTHKEYGIT_LDAP_FILTER
* AUTHKEYGIT_LDAP_ADDR
* AUTHKEYGIT_GIT_OPTIONS (defaults to 'no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty')

## Quick setup

Create volumes for your SSH server host keys and for your Gitolite config and repositories

* Docker >= 1.9

        docker volume create --name gitolite-sshkeys
        docker volume create --name gitolite-git

* Docker < 1.9

        docker create --name gitolite-data -v /etc/ssh/keys -v /var/lib/git tianon/true

Setup Gitolite with yourself as the administrator:

* Docker >= 1.10

        docker run --rm -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" -v gitolite-sshkeys:/etc/ssh/keys -v gitolite-git:/var/lib/git jgiannuzzi/gitolite true

* Docker == 1.9 (There is a bug in `docker run --rm` that removes volumes when removing the container)

        docker run --name gitolite-setup -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" -v gitolite-sshkeys:/etc/ssh/keys -v gitolite-git:/var/lib/git jgiannuzzi/gitolite true
        docker rm gitolite-setup

* Docker < 1.9

        docker run --rm -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" --volumes-from gitolite-data jgiannuzzi/gitolite true

Finally run your Gitolite container in the background:

* Docker >= 1.9

        docker run -d --name gitolite -p 22:22 -v gitolite-sshkeys:/etc/ssh/keys -v gitolite-git:/var/lib/git jgiannuzzi/gitolite

* Docker < 1.9

        docker run -d --name gitolite -p 22:22 --volumes-from gitolite-data jgiannuzzi/gitolite

You can then add users and repos by following the [official guide](https://github.com/sitaramc/gitolite#adding-users-and-repos).
