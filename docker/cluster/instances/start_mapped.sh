#!/bin/bash

set -e

cd $(dirname ${BASH_SOURCE[0]})/..
source ./instances/.env.sh

echo "ISAAC_CACHE_DIR:$ISAAC_CACHE_DIR"

start_instance() {
    singularity exec --fakeroot --net \
        --network fakeroot \
        --nv --containall \
        --dns "${NAMESERVER}" \
        --env ACCEPT_EULA=Y \
        -B ${ISAAC_CACHE_DIR}/cache/kit:/isaac-sim/kit/cache:rw \
        -B ${ISAAC_CACHE_DIR}/cache/ov:/root/.cache/ov:rw \
        -B ${ISAAC_CACHE_DIR}/cache/pip:/root/.cache/pip:rw \
        -B ${ISAAC_CACHE_DIR}/cache/glcache:/root/.cache/nvidia/GLCache:rw \
        -B ${ISAAC_CACHE_DIR}/cache/computecache:/root/.nv/ComputeCache:rw \
        -B ${ISAAC_CACHE_DIR}/logs:/root/.nvidia-omniverse/logs:rw \
        -B ${ISAAC_CACHE_DIR}/data:/root/.local/share/ov/data:rw \
        -B ${ISAAC_CACHE_DIR}/documents:/root/Documents:rw \
        --network-args "portmap=$((BASEPORT +  0)):8011/tcp" \
        --network-args "portmap=$((BASEPORT +  1)):8012/tcp" \
        --network-args "portmap=$((BASEPORT +  2)):8211/tcp" \
        --network-args "portmap=$((BASEPORT +  3)):8891/tcp" \
        --network-args "portmap=$((BASEPORT +  4)):8899/tcp" \
        --network-args "portmap=$((BASEPORT +  5)):47995/tcp" \
        --network-args "portmap=$((BASEPORT +  6)):47996/tcp" \
        --network-args "portmap=$((BASEPORT +  7)):47997/tcp" \
        --network-args "portmap=$((BASEPORT +  8)):47998/tcp" \
        --network-args "portmap=$((BASEPORT +  9)):47999/tcp" \
        --network-args "portmap=$((BASEPORT + 10)):48000/tcp" \
        --network-args "portmap=$((BASEPORT + 11)):48001/tcp" \
        --network-args "portmap=$((BASEPORT + 12)):48002/tcp" \
        --network-args "portmap=$((BASEPORT + 13)):48003/tcp" \
        --network-args "portmap=$((BASEPORT + 14)):48004/tcp" \
        --network-args "portmap=$((BASEPORT + 15)):48005/tcp" \
        --network-args "portmap=$((BASEPORT + 16)):48006/tcp" \
        --network-args "portmap=$((BASEPORT + 17)):48007/tcp" \
        --network-args "portmap=$((BASEPORT + 18)):48008/tcp" \
        --network-args "portmap=$((BASEPORT + 19)):48009/tcp" \
        --network-args "portmap=$((BASEPORT + 20)):48010/tcp" \
        --network-args "portmap=$((BASEPORT + 21)):48011/tcp" \
        --network-args "portmap=$((BASEPORT + 22)):48012/tcp" \
        --network-args "portmap=$((BASEPORT + 23)):49000/tcp" \
        --network-args "portmap=$((BASEPORT + 24)):49001/tcp" \
        --network-args "portmap=$((BASEPORT + 25)):49002/tcp" \
        --network-args "portmap=$((BASEPORT + 26)):49003/tcp" \
        --network-args "portmap=$((BASEPORT + 27)):49004/tcp" \
        --network-args "portmap=$((BASEPORT + 28)):49005/tcp" \
        --network-args "portmap=$((BASEPORT + 29)):49006/tcp" \
        --network-args "portmap=$((BASEPORT + 30)):49007/tcp" \
        --network-args "portmap=$((BASEPORT + 31)):49100/tcp" \
        ${ISAAC_CACHE_DIR}/${ISAAC_IMAGE_NAME} /bin/bash
}
start_instance
