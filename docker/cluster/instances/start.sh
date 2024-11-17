#!/bin/bash

set -e

cd $(dirname ${BASH_SOURCE[0]})/..
source ./instances/.env.sh

echo "ISAAC_CACHE_DIR:$ISAAC_CACHE_DIR"
mkdir -p ${ISAAC_CACHE_DIR}/kit_cache

start_instance() {
    singularity exec --fakeroot \
        --nv --containall \
         --env ACCEPT_EULA=Y \
        -B ${ISAAC_CACHE_DIR}/cache/kit:/isaac-sim/kit/cache:rw \
        -B ${ISAAC_CACHE_DIR}/cache/ov:/root/.cache/ov:rw \
        -B ${ISAAC_CACHE_DIR}/cache/pip:/root/.cache/pip:rw \
        -B ${ISAAC_CACHE_DIR}/cache/glcache:/root/.cache/nvidia/GLCache:rw \
        -B ${ISAAC_CACHE_DIR}/cache/computecache:/root/.nv/ComputeCache:rw \
        -B ${ISAAC_CACHE_DIR}/logs:/root/.nvidia-omniverse/logs:rw \
        -B ${ISAAC_CACHE_DIR}/data:/root/.local/share/ov/data:rw \
        -B ${ISAAC_CACHE_DIR}/documents:/root/Documents:rw \
        -B ${ISAAC_CACHE_DIR}/kit_cache:/isaac-sim/kit/cache \
        ${ISAAC_CACHE_DIR}/${ISAAC_IMAGE_NAME} /bin/bash
}
start_instance
