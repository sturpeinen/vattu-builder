#!/bin/sh -e

umask 0077

ALPINE_VERSION=3.22
APORTS_VERSION=3.22.1

print_usage() {
    echo "Usage: build.sh HOSTNAME ARCH"
    echo
    echo "Parameters:"
    echo "  HOSTNAME    The hostname for the target image."
    echo "  ARCH        The target architecture. Valid values are:"
    echo "                - aarch64"
    echo "                - armv7"
    echo "                - armhf"
}

if [ $# -ge 2 ]; then
    HOSTNAME=$1
    ARCH=$2

    case "${ARCH}" in
      "aarch64"|"armv7"|"armhf")
        ;;
      *)
        echo "Error: Invalid ARCH value '${ARCH}'." >&2
        print_usage
        exit 1
        ;;
    esac
else
    print_usage
    exit 1
fi

docker build \
    --build-arg HOSTNAME="${HOSTNAME}" \
    --build-arg ALPINE_VERSION="${ALPINE_VERSION}" \
    --build-arg APORTS_VERSION="${APORTS_VERSION}" \
    --build-arg ARCH="${ARCH}" \
    -t vattu-builder .

[ ! -d build ] && mkdir -p build
CID="$(docker create vattu-builder)"
docker cp \
    "${CID}:/build/alpine-vattu-${APORTS_VERSION}-${ARCH}.tar.gz" \
    "build/${HOSTNAME}-${APORTS_VERSION}-${ARCH}.tar.gz"
docker rm "${CID}"
