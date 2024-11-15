#!/bin/bash

# X11 forward setting script
# Source from: Isaac Lab v1.0.0

STATEFILE="$(realpath $(dirname ${BASH_SOURCE[0]})/.container.yaml)"
if ! [ -f "$STATEFILE" ]; then
    touch $STATEFILE
    echo "STATEFILE: $STATEFILE"
fi

install_yq() {
    # Installing yq to handle file parsing
    # Installation procedure from here: https://github.com/mikefarah/yq
    read -p "[INFO] Required 'yq' package could not be found. Would you like to install it via wget? (y/N)" yq_answer
    if [ "$yq_answer" != "${yq_answer#[Yy]}" ]; then
        sudo snap install yq
    else
        echo "[INFO] Exiting because yq was not installed"
        exit
    fi
}

set_statefile_variable() {
    # Stores key $1 with value $2 in yaml $STATEFILE
    yq -i '.["'"$1"'"] = "'"$2"'"' $STATEFILE
}

load_statefile_variable() {
    # Loads key $1 from yaml $STATEFILE as an envvar
    # If key does not exist, the loaded var will equal "null"
    eval $1="$(yq ".$1" $STATEFILE)"
}

delete_statefile_variable() {
    # Deletes key $1 from yaml $STATEFILE
    yq -i "del(.$1)" $STATEFILE
}

install_xauth() {
    # check if xauth is installed
    read -p "[INFO] xauth is not installed. Would you like to install it via apt? (y/N) " xauth_answer
    if [ "$xauth_answer" != "${xauth_answer#[Yy]}" ]; then
        sudo apt update && sudo apt install xauth
    else
        echo "[INFO] Did not install xauth. Full X11 forwarding not enabled."
    fi
}

# This is modeled after Rocker's x11 forwarding extension
# https://github.com/osrf/rocker
configure_x11() {
    if ! command -v xauth &> /dev/null; then
        install_xauth
    fi
    load_statefile_variable __ISAACSIM_TMP_XAUTH
    # Create temp .xauth file to be mounted in the container
    if [ "$__ISAACSIM_TMP_XAUTH" = "null" ] || [ ! -f "$__ISAACSIM_TMP_XAUTH" ]; then
        __ISAACSIM_TMP_XAUTH=$(mktemp --suffix=".xauth")
        set_statefile_variable __ISAACSIM_TMP_XAUTH $__ISAACSIM_TMP_XAUTH
        # Extract MIT-MAGIC-COOKIE for current display | Change the 'connection family' to FamilyWild (ffff) | merge into tmp .xauth file
        # https://www.x.org/archive/X11R6.8.1/doc/Xsecurity.7.html#toc3
        xauth_cookie= xauth nlist ${DISPLAY} | sed -e s/^..../ffff/ | xauth -f $__ISAACSIM_TMP_XAUTH nmerge -
    fi
    # Export here so it's an envvar for the called Docker commands
    export __ISAACSIM_TMP_XAUTH
    add_yamls="$add_yamls --file x11.yaml "
    # TODO: Add check to make sure Xauth file is correct
}

x11_check() {
    load_statefile_variable __ISAACSIM_X11_FORWARDING_ENABLED
    if [ "$__ISAACSIM_X11_FORWARDING_ENABLED" = "null" ]; then
        echo "[INFO] X11 forwarding from the Isaac Sim container is off by default."
        echo "[INFO] It will fail if there is no display, or this script is being run via ssh without proper configuration."
        read -p "Would you like to enable it? (y/N) " x11_answer
        if [ "$x11_answer" != "${x11_answer#[Yy]}" ]; then
            __ISAACSIM_X11_FORWARDING_ENABLED=1
            set_statefile_variable __ISAACSIM_X11_FORWARDING_ENABLED 1
            echo "[INFO] X11 forwarding is enabled from the container."
        else
            __ISAACSIM_X11_FORWARDING_ENABLED=0
            set_statefile_variable __ISAACSIM_X11_FORWARDING_ENABLED 0
            echo "[INFO] X11 forwarding is disabled from the container."
        fi
    else
        echo "[INFO] X11 Forwarding is configured as $__ISAACSIM_X11_FORWARDING_ENABLED in .container.yaml"
        if [ "$__ISAACSIM_X11_FORWARDING_ENABLED" = "1" ]; then
            echo "[INFO] To disable X11 forwarding, set __ISAACSIM_X11_FORWARDING_ENABLED=0 in .container.yaml"
        else
            echo "[INFO] To enable X11 forwarding, set __ISAACSIM_X11_FORWARDING_ENABLED=1 in .container.yaml"
        fi
    fi

    if [ "$__ISAACSIM_X11_FORWARDING_ENABLED" = "1" ]; then
        configure_x11
    fi
}

x11_cleanup() {
    load_statefile_variable __ISAACSIM_TMP_XAUTH
    if ! [ "$__ISAACSIM_TMP_XAUTH" = "null" ] && [ -f "$__ISAACSIM_TMP_XAUTH" ]; then
        echo "[INFO] Removing temporary Isaac Sim .xauth file $__ISAACSIM_TMP_XAUTH."
        rm $__ISAACSIM_TMP_XAUTH
        delete_statefile_variable __ISAACSIM_TMP_XAUTH
    fi
}

if ! command -v yq &> /dev/null; then
    install_yq
fi