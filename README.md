# Docker image for Gitolite

This image allows you to run a git server in a container with OpenSSH and [Gitolite](https://github.com/sitaramc/gitolite#readme).

Based on Alpine Linux.

## Quick setup

Create volumes for your SSH server host keys and for your Gitolite config and repositories

        docker volume create --name gitolite-sshkeys
        docker volume create --name gitolite-git

Setup Gitolite with yourself as the administrator:

        docker run --rm -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" -v gitolite-sshkeys:/etc/ssh/keys -v gitolite-git:/var/lib/git jgiannuzzi/gitolite true


Finally run your Gitolite container in the background:

        docker run -d --name gitolite -p 22:22 -v gitolite-sshkeys:/etc/ssh/keys -v gitolite-git:/var/lib/git jgiannuzzi/gitolite


You can then add users and repos by following the [official guide](https://github.com/sitaramc/gitolite#adding-users-and-repos).
