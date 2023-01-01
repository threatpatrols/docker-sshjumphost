FROM alpine:3.17.0@sha256:c0d488a800e4127c334ad20d61d7bc21b4097540327217dfab52262adc02380c

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
    && apk add --no-cache iputils \
    && echo "# " > /etc/motd \
    && echo "# sshjumphost" >> /etc/motd \
    && echo "# version: ${COMMIT_REF} (${COMMIT_HASH})" >> /etc/motd \
    && echo "# documentation: https://github.com/threatpatrols/docker-sshjumphost" >> /etc/motd \
    && echo "# " >> /etc/motd \
    && echo "# NB: set the SSH_SHELL environment variable to enable a login-shell at the sshjumphost." >> /etc/motd \
    && echo "# " >> /etc/motd \
    && chmod +x /usr/sbin/sshjumphost \
    && mkdir -p ${DATA_PATH}/cakeys \
    && mkdir -p ${DATA_PATH}/hostkeys \
    && mkdir -p ${DATA_PATH}/userkeys \
    && mkdir -p ${DATA_PATH}/home

EXPOSE 22/tcp

VOLUME ${DATA_PATH}/hostkeys

ENTRYPOINT ["sshjumphost"]
