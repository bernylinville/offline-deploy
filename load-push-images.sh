#!/bin/bash

set -euo pipefail

REGISTRY_PORT=${REGISTRY_PORT:-35000}
LOCAL_REGISTRY=${LOCAL_REGISTRY:-"localhost:${REGISTRY_PORT}"}
LOCAL_REGISTRY=172.18.182.133:35000

BASEDIR="."
if [ ! -d images ] && [ -d ../outputs ]; then
    BASEDIR="../outputs"
fi

load_images() {
    for image in "${BASEDIR}"/images/*.tar.gz; do
        echo "===> Loading ${image}"
        docker load -i "${image}" || exit 1
    done
}

push_images() {
    images=$(cat $BASEDIR/images/*.list)
    for image in $images; do

        # Removes specific repo parts from each image for kubespray
        newImage=$image
        for repo in registry.k8s.io k8s.gcr.io gcr.io docker.io quay.io container-registry.oracle.com; do
            # newImage=$(echo ${newImage} | sed s@^${repo}/@@)
            newImage=${newImage#"$repo/"}
        done

        newImage=${LOCAL_REGISTRY}/${newImage}

        echo "===> Tag ${image} -> ${newImage}"
        docker tag "${image}" "${newImage}" || exit 1

        echo "===> Push ${newImage}"
        docker push "${newImage}" || exit 1
    done
}

load_images
push_images
