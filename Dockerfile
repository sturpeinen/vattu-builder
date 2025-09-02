FROM alpine:3.22.1

ARG HOSTNAME
ARG ALPINE_VERSION
ARG APORTS_VERSION
ARG ARCH

RUN apk update && \
    apk add alpine-conf alpine-sdk curl squashfs-tools sudo && \
    addgroup root abuild && \
    abuild-keygen -i -a -n

RUN curl -sSf "https://gitlab.alpinelinux.org/alpine/aports/-/archive/v${APORTS_VERSION}/aports-v${APORTS_VERSION}.tar.bz2" | \
  tar xjf - -C / && \
  ln -s "/aports-v${APORTS_VERSION}" /aports

COPY apkovl /apkovl
COPY mkimg.vattu.sh genapkovl.sh /aports/scripts/
RUN chmod u+x /aports/scripts/*.sh

WORKDIR /aports/scripts

RUN sh mkimage.sh \
    --arch "${ARCH}" \
    --tag "${APORTS_VERSION}" \
    --profile vattu \
    --repository "https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main/" \
    --repository "https://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community/" \
    --outdir /build
