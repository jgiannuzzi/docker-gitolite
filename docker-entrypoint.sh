#!/bin/sh

# if command is sshd, set it up correctly
if [ "${1}" = 'sshd' ]; then
  set -- dumb-init /usr/sbin/sshd -D -e

  # Setup SSH HostKeys if needed
  for algorithm in rsa dsa ecdsa ed25519
  do
    keyfile=/etc/ssh/keys/ssh_host_${algorithm}_key
    [ -f $keyfile ] || ssh-keygen -q -N '' -f $keyfile -t $algorithm
    grep -q "HostKey $keyfile" /etc/ssh/sshd_config || echo "HostKey $keyfile" >> /etc/ssh/sshd_config
  done

  # Setup AuthorizedKeysCommand if needed
  if [ -z "$(grep '^AuthorizedKeysCommand' /etc/ssh/sshd_config)" ]; then
    echo 'AuthorizedKeysCommand /usr/local/bin/auth_key_git' >> /etc/ssh/sshd_config
  fi

  # Setup AuthorizedKeysCommandUser user if needed
  if [ -z "$(grep '^AuthorizedKeysCommandUser' /etc/ssh/sshd_config)" ]; then
    echo 'AuthorizedKeysCommandUser root' >> /etc/ssh/sshd_config
  fi
fi

if [ ! -f "/etc/authkeygit/authkeygitrc" ] || [ -n "${CONFD_CMDLINE}" ]; then
  mkdir -p /etc/authkeygit
  if ! eval ${CONFD_CMDLINE:-confd -onetime -backend env}; then
    echo "confd failed" >&2
    exit 1
  fi
fi

# Fix permissions at every startup
chown -R git:git ~git

# Setup gitolite admin  
if [ ! -f ~git/.ssh/authorized_keys ]; then
  if [ -n "$SSH_KEY" ]; then
    [ -n "$SSH_KEY_NAME" ] || SSH_KEY_NAME=admin
    echo "$SSH_KEY" > "/tmp/$SSH_KEY_NAME.pub"
    su - git -c "gitolite setup -pk \"/tmp/$SSH_KEY_NAME.pub\""
    rm "/tmp/$SSH_KEY_NAME.pub"
  else
    echo "You need to specify SSH_KEY on first run to setup gitolite"
    echo "You can also use SSH_KEY_NAME to specify the key name (optional)"
    echo 'Example: docker run -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" jgiannuzzi/gitolite'
    exit 1
  fi
# Check setup at every startup
else
  su - git -c "gitolite setup"
fi

exec "$@"
