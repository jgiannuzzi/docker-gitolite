#!/bin/sh

# disable ssh password authentication
sed -i 's@#PasswordAuthentication yes@PasswordAuthentication no@g' /etc/ssh/sshd_config

# if command is sshd, set it up correctly
if [ "${1}" = 'sshd' ]; then
  set -- /usr/sbin/sshd -D -e

  # Setup SSH HostKeys if needed
  for algorithm in rsa dsa ecdsa ed25519
  do
    keyfile=/etc/ssh/keys/ssh_host_${algorithm}_key
    [ -f $keyfile ] || ssh-keygen -q -N '' -f $keyfile -t $algorithm
    chmod 600 $keyfile
    grep -q "HostKey $keyfile" /etc/ssh/sshd_config || echo "HostKey $keyfile" >> /etc/ssh/sshd_config
  done
  # Disable unwanted authentications
  perl -i -pe 's/^#?((?!Kerberos|GSSAPI)\w*Authentication)\s.*/\1 no/; s/^(PubkeyAuthentication) no/\1 yes/' /etc/ssh/sshd_config
  # Disable sftp subsystem
  perl -i -pe 's/^(Subsystem\ssftp\s)/#\1/' /etc/ssh/sshd_config
  # Override the SSH port if an override is set
  if [ "${GITOLITE_SSH_OVERRIDE}" != "" ];then
	  echo "Port = ${GITOLITE_SSH_OVERRIDE}" >> /etc/ssh/sshd_config
  fi
fi

# Fix permissions at every startup
chown -R git:git ~git

# Setup gitolite admin  
if [ ! -f ~git/.ssh/authorized_keys ]; then
  if [ -n "$SSH_KEY" ]; then
    [ -n "$SSH_KEY_NAME" ] || SSH_KEY_NAME=admin
    echo "$SSH_KEY" | tr -d '\n' > "/tmp/$SSH_KEY_NAME.pub"
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
