# Docker image for Gitolite

This image allows you to run a git server in a container with OpenSSH and
[Gitolite](https://github.com/sitaramc/gitolite#readme).

Based on Alpine Linux.

## Quick(est) setup using Docker Compose

1.  Clone this repository:

    ```sh
    $ git clone https://github.com/gbence/docker-gitolite
    ```

2.  Set up SSH keys, administrator and repositories:

    ```sh
    $ docker compose run --rm -e SSH_KEY="$(ssh-add -L)" \
        -e SSH_KEY_NAME="$(whoami)" \
        server true
    ```

3.  Start the service:

    ```sh
    $ docker compose up -d
    ```

## Quick setup using Docker

1.  Create volumes for your SSH server host keys and for your Gitolite config
    and repositories:

    ```sh
    $ docker volume create --name gitolite-sshkeys
    $ docker volume create --name gitolite-git
    ```

2.  Set up Gitolite with yourself as the administrator:

    ```sh
    $ docker run --rm -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" \
        -e SSH_KEY_NAME="$(whoami)" \
        -v gitolite-sshkeys:/etc/ssh/keys \
        -v gitolite-git:/var/lib/git \
        jgiannuzzi/gitolite true
    ```

3.  Finally run your Gitolite container in the background:

    ```sh
    $ docker run -d --name gitolite -p 22:22 \
        -v gitolite-sshkeys:/etc/ssh/keys \
        -v gitolite-git:/var/lib/git \
        jgiannuzzi/gitolite
    ```

You can then add users and repos by following the [official
guide](https://github.com/sitaramc/gitolite#adding-users-and-repos).
