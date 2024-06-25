
# https://hub.docker.com/_/debian/tags
FROM debian:stable-slim

# Hello
LABEL maintainer="Nicholas de Jong <ndejong@threatpatrols.com>"
LABEL source="https://github.com/threatpatrols/docker-sshjumphost"

ARG COMMIT_REF="${COMMIT_REF}"
LABEL COMMIT_REF="${COMMIT_REF}"

ARG COMMIT_HASH="${COMMIT_HASH}"
LABEL COMMIT_HASH="${COMMIT_HASH}"

ENV DATA_PATH="/data"

COPY sshjumphost /usr/sbin/sshjumphost

RUN set -x && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y openssh-server openssh-client iputils-ping iproute2 && \
    apt-get install -y ash && \
    \
    systemctl disable ssh && \
    mv /etc/ssh/ssh*_config /tmp/ && \
    rm -Rf /etc/ssh/* && \
    mv /tmp/ssh*_config /etc/ssh/ && \
    mkdir /run/sshd && \
    chown root:root /run/sshd && \
    \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN set -x && \
    echo "# " > /etc/motd && \
    echo "# sshjumphost" >> /etc/motd && \
    echo "# version: ${COMMIT_REF} (${COMMIT_HASH})" >> /etc/motd && \
    echo "# documentation: https://github.com/threatpatrols/docker-sshjumphost" >> /etc/motd && \
    echo "# " >> /etc/motd && \
    echo "# NB: set the SSH_SHELL environment variable to enable a login-shell at the sshjumphost." >> /etc/motd && \
    echo "# " >> /etc/motd

RUN set -x && \
    chmod +x /usr/sbin/sshjumphost && \
    mkdir -p ${DATA_PATH}/cakeys && \
    mkdir -p ${DATA_PATH}/hostkeys && \
    mkdir -p ${DATA_PATH}/userkeys

EXPOSE 22/tcp

VOLUME ${DATA_PATH}/hostkeys

ENTRYPOINT ["sshjumphost"]
