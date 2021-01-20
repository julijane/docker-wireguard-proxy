FROM alpine:latest
RUN set -ex ; \
    apk --no-cache add wireguard-tools iptables ip6tables inotify-tools bash
COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
