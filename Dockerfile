# Use the latest available, fully specified Alpine version
ARG ALPINE_VERSION=3.18.3

# Set up the base for the `runtime` layer
FROM alpine:${ALPINE_VERSION} AS runtime

# Install OpenSSH server and Gitolite and unlock the automatically-created git
# user
RUN set -x \
    && apk add --no-cache gitolite openssh \
    && passwd -u git

# Volume used to store SSH host keys, generated on first run
VOLUME /etc/ssh/keys

# Volume used to store all Gitolite data (keys, config and repositories), initialized on first run
VOLUME /var/lib/git

# Entrypoint responsible for SSH host keys generation, and Gitolite data initialization
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose port 22 to access SSH
EXPOSE 22

# Default command is to run the SSH server
CMD ["sshd"]
