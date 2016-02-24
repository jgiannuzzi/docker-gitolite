FROM alpine:3.3

RUN set -x \
 && apk add --update gitolite openssh \
 && rm -rf /var/cache/apk/* \
 && passwd -u git

VOLUME /etc/ssh/keys
VOLUME /var/lib/git

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 22

CMD ["sshd"]
