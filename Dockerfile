FROM alpine:edge

# Install OpenSSH server and Gitolite
# Unlock the automatically-created git user
RUN set -x \
 && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
 && apk add --no-cache gitolite openssh dumb-init python3 py-pyldap confd \
 && pip3 install git+https://github.com/lse/auth-key-git.git --install-option="--install-scripts=/usr/local/bin" \
 && passwd -u git

# Volume used to store SSH host keys, generated on first run
VOLUME /etc/ssh/keys

# Volume used to store all Gitolite data (keys, config and repositories), initialized on first run
VOLUME /var/lib/git

# Entrypoint responsible for SSH host keys generation, and Gitolite data initialization
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Auth key git config (via confd)
COPY ["confd/conf.d/auth-key-git.toml", "/etc/confd/conf.d/auth-key-git.toml"]
COPY ["confd/templates/auth-key-git.conf.tmpl", "/etc/confd/templates/auth-key-git.conf.tmpl"]

# Expose port 22 to access SSH
EXPOSE 22

# Default command is to run the SSH server
CMD ["sshd"]
