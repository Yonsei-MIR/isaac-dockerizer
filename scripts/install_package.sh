#!/bin/bash

set -e

# Change directory to source dir
cd $DOCKER_PACKAGE_PATH

# Install poetry
${DOCKER_ISAACSIM_ROOT_PATH}/python.sh -m pip install poetry

# Turn off virtualenv creation
${DOCKER_ISAACSIM_ROOT_PATH}/python.sh -m poetry config virtualenvs.create false

# Install current directory
${DOCKER_ISAACSIM_ROOT_PATH}/python.sh -m poetry install
