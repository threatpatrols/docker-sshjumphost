FROM alpine:3.16.2

LABEL maintainer="Nicholas de Jong <ndejong@threatpatrols.com>"

ENV DATA_PATH="/data"

COPY sshjumphost /usr/sbin/sshjumphost

RUN set -x \
    && apk add --no-cache openssh-server \
    && apk add --no-cache openssh-client \
    && echo "# " > /etc/motd \
    && echo "# sshjumphost: refer to documentation" >> /etc/motd \
    && echo "# https://hub.docker.com/r/threatpatrols/sshjumphost" >> /etc/motd \
    && echo "# " >> /etc/motd \
    && echo "# NB: set the SSH_SHELL environment variable to enable a login-shell at the sshjumphost." >> /etc/motd \
    && echo "# " >> /etc/motd \
    && chmod +x /usr/sbin/sshjumphost \
    && mkdir -p ${DATA_PATH}/cakeys \
    && mkdir -p ${DATA_PATH}/hostkeys \
    && mkdir -p ${DATA_PATH}/userkeys \
    && mkdir -p ${DATA_PATH}/home \

EXPOSE 22/tcp

VOLUME ${DATA_PATH}/hostkeys

ENTRYPOINT ["sshjumphost"]
