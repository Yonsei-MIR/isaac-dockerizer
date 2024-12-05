#!/usr/bin/env bash

#==
# Configurations
#==

# Exits if error occurs
set -e

# Set tab-spaces
tabs 4

# get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load X11 settings
source $SCRIPT_DIR/x11_utils.sh

#==
# Functions
#==

# print the usage description
print_help () {
    echo -e "\nusage: $(basename "$0") [-h] [run] [start] [stop] -- Utility for handling docker in Isaac Sim."
    echo -e "\noptional arguments:"
    echo -e "\t-h, --help                  Display the help content."
    echo -e "\tbuild [profile]             Build the docker image."
    echo -e "\tstart [profile]             Create the container in detached mode. (Run 'build' first.)"
    echo -e "\tattach [profile]            Attach to running Isaac Sim container."
    echo -e "\tenter [profile]             Begin a new bash process within an existing Isaac Sim container."
    echo -e "\tstop [profile]              Stop the docker container and remove it."
    echo -e "\tconfig [profile]            Parse, resolve and render compose file in canonical format."
    echo -e "\n"
    echo -e "[profile] is the optional container profile specification and [job_args] optional arguments specific"
    echo -e "to the executed script"
    echo -e "\n" >&2
}

# Function to check docker versions
# If docker version is more than 25, the script errors out.
check_docker_version() {
    # Retrieve Docker version
    docker_version=$(docker --version | awk '{ print $3 }')
    apptainer_version=$(apptainer --version | awk '{ print $3 }')

    # Check if version is above 25.xx
    if [ "$(echo "${docker_version}" | cut -d '.' -f 1)" -ge 25 ]; then
        echo "[ERROR]: Docker version ${docker_version} is not compatible with Apptainer version ${apptainer_version}. Exiting."
        exit 1
    else
        echo "[INFO]: Building singularity with docker version: ${docker_version} and Apptainer version: ${apptainer_version}."
    fi
}

# Produces container_profile, add_profiles, and add_envs from the image_extension arg
resolve_image_extension() {
    # If no profile was passed, we default to 'base'
    container_profile=${1:-"base"}
    # check if the second argument has to be a profile or can be a job argument instead
    necessary_profile=${2:-true}

    # check if a .env.$container_profile file exists
    # if the argument is necessary a profile, then the file must exists otherwise an info is printed
    if [ "$necessary_profile" = true ] && [ ! -f $SCRIPT_DIR/.env.$container_profile ]; then
        echo "[Error] The profile '$container_profile' has no .env.$container_profile file!" >&2;
        exit 1
    elif [ ! -f $SCRIPT_DIR/.env.$container_profile ]; then
        echo "[INFO] No .env.$container_profile found, assume second argument is no profile! Will use default container!" >&2;
        container_profile="base"
    fi

    add_yamls="--file docker-compose.yaml"

    add_profiles="--profile $container_profile"
    # We will need .env.base regardless of profile
    add_envs="--env-file .env.base"
    # The second argument is interpreted as the profile to use.
    # We will select the base profile by default.
    # This will also determine the .env file that is loaded
    if [ "$container_profile" != "base" ]; then
        # We have to load multiple .env files here in order to combine
        # them for the args from base required for extensions, (i.e. DOCKER_USER_HOME)
        add_envs="$add_envs --env-file .env.$container_profile"
    fi
}

# Prints a warning message and exits if the passed container is not running
is_container_running() {
    container_name="$1"
    if [ "$( docker container inspect -f '{{.State.Status}}' $container_name 2> /dev/null)" != "running" ]; then
        echo "[Error] The '$container_name' container is not running!" >&2;
        exit 1
    fi
}

#==
# Main
#==

# check argument provided
if [ -z "$*" ]; then
    echo "[Error] No arguments provided." >&2;
    print_help
    exit 1
fi

# check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "[Error] Docker is not installed! Please check the 'Docker Guide' for instruction." >&2;
    exit 1
fi

if ! command -v yq &> /dev/null; then
    install_yq
fi

# parse arguments
mode="$1"
profile_arg="$2" # Capture the second argument as the potential profile argument

# Check mode argument and resolve the container profile
case $mode in
    build|start|attach|enter|stop|config)
        resolve_image_extension "$profile_arg" true
        ;;
    *)
        # Not recognized mode
        echo "[Error] Invalid command provided: $mode"
        print_help
        exit 1
        ;;
esac

# Produces a nice print statement stating which container profile is being used
echo "[INFO] Using container profile: $container_profile"

# Set env variables of base
source $SCRIPT_DIR/.env.base

# Set image name (with tag)
IMAGE_NAME="mirlab/isaac-sim:${ISAACSIM_VERSION}-$container_profile"

# Set container name
# CONTAINER_NAME="$USER-$(echo $IMAGE_NAME | sed 's|:|-|')"
CONTAINER_NAME="${USER}-isaac-${container_profile}-dockerize-${ISAACSIM_VERSION}"

# resolve mode
case $mode in
    build)
        echo "[INFO] Building the docker image $IMAGE_NAME..."
        pushd ${SCRIPT_DIR} > /dev/null 2>&1
        # We have to build the base image as a separate step,
        # in case we are building a profile which depends
        # upon
        docker compose --file docker-compose.yaml --env-file .env.base build isaac-sim-base
        docker compose $add_yamls $add_profiles $add_envs build isaac-sim-$container_profile
        
        popd > /dev/null 2>&1
        ;;
    start)
        echo "[INFO] Starting the container $CONTAINER_NAME in the background..."
        pushd ${SCRIPT_DIR} > /dev/null 2>&1
        # Determine if we want x11 forwarding enabled
        x11_check
        echo "profiles: $add_profiles"
        echo "yamls: $add_yamls"
        echo "envs: $add_envs"
        docker compose $add_yamls $add_profiles $add_envs up --detach --remove-orphans
        popd > /dev/null 2>&1
        ;;
    attach)
        is_container_running $CONTAINER_NAME
        echo "[INFO] Attaching the existing '$CONTAINER_NAME' container in a bash session..."
        pushd ${SCRIPT_DIR} > /dev/null 2>&1
        docker attach $CONTAINER_NAME
        popd > /dev/null 2>&1
        ;;
    enter)
        # Check that desired container is running, exit if it isn't
        is_container_running $CONTAINER_NAME
        echo "[INFO] Entering the existing '$CONTAINER_NAME' container in a bash session..."
        pushd ${SCRIPT_DIR} > /dev/null 2>&1
        docker exec --interactive --tty $CONTAINER_NAME bash
        popd > /dev/null 2>&1
        ;;
    stop)
        # Check that desired container is running, exit if it isn't
        is_container_running $CONTAINER_NAME
        echo "[INFO] Stopping the launched docker container $CONTAINER_NAME..."
        pushd ${SCRIPT_DIR} > /dev/null 2>&1
        docker compose --file docker-compose.yaml $add_profiles $add_envs down
        x11_cleanup
        popd > /dev/null 2>&1
        ;;
    config)
        pushd ${SCRIPT_DIR} > /dev/null 2>&1
        docker compose $add_yamls $add_envs $add_profiles config
        ;;
    *)
        # Not recognized mode
        echo "[Error] Invalid command provided: $mode"
        print_help
        exit 1
        ;;
esac
