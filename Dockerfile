
# https://hub.docker.com/_/alpine/tags
FROM alpine:3.19.1

LABEL maintainer="Nicholas de Jong <ndejong@threatpatrols.com>"

ARG COMMIT_REF="${COMMIT_REF}"
LABEL COMMIT_REF="${COMMIT_REF}"

ARG COMMIT_HASH="${COMMIT_HASH}"
LABEL COMMIT_HASH="${COMMIT_HASH}"

ENV DATA_PATH="/data"

COPY sshjumphost /usr/sbin/sshjumphost

RUN set -x \
    && apk add --no-cache openssh-server \
    && apk add --no-cache openssh-client \
    && apk add --no-cache iputils

RUN set -x \
    && echo "# " > /etc/motd \
    && echo "# sshjumphost" >> /etc/motd \
    && echo "# version: ${COMMIT_REF} (${COMMIT_HASH})" >> /etc/motd \
    && echo "# documentation: https://github.com/threatpatrols/docker-sshjumphost" >> /etc/motd \
    && echo "# " >> /etc/motd \
    && echo "# NB: set the SSH_SHELL environment variable to enable a login-shell at the sshjumphost." >> /etc/motd \
    && echo "# " >> /etc/motd

RUN set -x \
    && chmod +x /usr/sbin/sshjumphost \
    && mkdir -p ${DATA_PATH}/cakeys \
    && mkdir -p ${DATA_PATH}/hostkeys \
    && mkdir -p ${DATA_PATH}/userkeys \
    && mkdir -p ${DATA_PATH}/home

EXPOSE 22/tcp

VOLUME ${DATA_PATH}/hostkeys

ENTRYPOINT ["sshjumphost"]
