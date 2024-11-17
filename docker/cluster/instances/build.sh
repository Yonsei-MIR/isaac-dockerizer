#!/bin/bash

set -e

cd $(dirname ${BASH_SOURCE[0]})/..
source ./instances/.env.sh

setup_directories() {
    # Check and create directories
    for dir in \
        "${ISAAC_CACHE_DIR}/cache/kit" \
        "${ISAAC_CACHE_DIR}/cache/ov" \
        "${ISAAC_CACHE_DIR}/cache/pip" \
        "${ISAAC_CACHE_DIR}/cache/glcache" \
        "${ISAAC_CACHE_DIR}/cache/computecache" \
        "${ISAAC_CACHE_DIR}/logs" \
        "${ISAAC_CACHE_DIR}/data" \
        "${ISAAC_CACHE_DIR}/documents"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo "Created directory: $dir"
        fi
    done
}

simage_build() {
    mkdir -p $ISAAC_CACHE_DIR
    echo "[INFO] Isaac singularity cache directory: $ISAAC_CACHE_DIR"
    rm -rf $ISAAC_CACHE_DIR/${ISAAC_IMAGE_NAME}

    echo "[INFO] Extracting sandbox on tmp directory: ${ISAAC_CACHE_DIR}..."
    tar zxvf $ISAAC_SOURCE_ROOT/${ISAAC_IMAGE_NAME}.tar.gz -C $ISAAC_CACHE_DIR

    echo "[INFO] Extracting complete!"
    
    echo "[INFO] Setting up directories on singularity container..."
    singularity exec --fakeroot --writable \
        ${ISAAC_CACHE_DIR}/${ISAAC_IMAGE_NAME} \
        mkdir -p /isaac-sim/kit/cache 
    echo "[INFO] Setting done!"
}

setup_directories
simage_build