#!/bin/bash
set -exo pipefail

ANSIBLE_DIR=${ANSIBLE_DIR:-/home/berny/ansible}
NGINX_VERSION=${NGINX_VERSION:-1.26.2}
NGINX_PORT=${NGINX_PORT:-18080}
REGISTRY_VERSION=${REGISTRY_VERSION:-2.8.3}
REGISTRY_PORT=${REGISTRY_PORT:-35000}
REGISTRY_DIR=${REGISTRY_DIR:-/data/appdata/registry}

mkdir -p ${REGISTRY_DIR}


BASEDIR="."
if [ ! -d images ] && [ -d ../outputs ]; then
    BASEDIR="../outputs"
fi

for image in "${BASEDIR}"/images/*.tar.gz; do
    if echo "${image}" | grep -q "nginx\|registry"; then
        docker load -i "${image}" || exit 1
    fi
done

docker run -d \
    -p "${NGINX_PORT}:80" \
    --restart always \
    --name nginx \
    -v "${ANSIBLE_DIR}:/usr/share/nginx/html" \
    "nginx:${NGINX_VERSION}"

docker run -d \
    -p "${REGISTRY_PORT}:5000" \
    --restart always \
    --name registry \
    -v "${REGISTRY_DIR}:/var/lib/registry" \
    "registry:${REGISTRY_VERSION}"
