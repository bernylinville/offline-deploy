#!/bin/bash

set -euo pipefail

REGISTRY_PORT=${REGISTRY_PORT:-15000}
LOCAL_REGISTRY=${LOCAL_REGISTRY:-"localhost:${REGISTRY_PORT}"}
ANSIBLE_DIR=${ANSIBLE_DIR:-/home/berny/ansible}

docker run -it \
    -v "${ANSIBLE_DIR}":/ansible -v ~/.ssh:/root/.ssh \
    --rm "${LOCAL_REGISTRY}"/base/ansible:latest "$*"