#!/bin/bash

TEMP_DIR="/tmp/installerlist_XXXXXX/"
RACCOON_APP_DIR="$HOME/.Raccoon/content/apps/"
# For mktemp:

function error_exit () {
    echo "Error! Exiting!"
    exit 1
}

function adb_install_apps () {
    ARGUMENTS=( "$@" )

    for single_apk in "${ARGUMENTS[@]}"; do
        sudo adb install -r "$single_apk" > /dev/null && echo "Installed $single_apk"
    done
}

function check_versions() {
    ARGUMENTS=( "$@" )

    for single_apk in "${ARGUMENTS[@]}"; do
        app_name="$(echo "$single_apk" | awk -F '-' '{print $1}' | awk -F '/' '{print $2}')"
        app_version_device=$(sudo adb shell dumpsys package "$app_name" | awk -F ' ' '/versionCode=/ { print $1 }' | grep -Eo '[0-9]+')
        app_version_host="$(echo "$single_apk" | awk -F '-' '{print $2}' | grep -Eo '[0-9]+')"

        if [[ "$app_version_host" -le "$app_version_device" ]]; then
            rm "$single_apk"
        fi

    done

    if [[ -z $(ls -A "$TEMP_DIR") ]]; then
        echo "Directory empty, nothing to do"
        exit 0
    fi
}

sudo adb kill-server
sudo adb devices
sudo adb wait-for-device || error_exit

if [[ ! -d "$TEMP_DIR" ]]; then
    if [[ $(command -v mktemp) ]]; then
        TEMP_DIR=$(mktemp -d "$TEMP_DIR")
    else
        echo "mktemp is not installed!"; error_exit
    fi
fi

if [[ -d "$RACCOON_APP_DIR" ]]; then
    cd "$RACCOON_APP_DIR" || error_exit

    for each_directory in *; do
        cd "$each_directory" || error_exit
        read -ra all_apks <<< "$(echo ./*.apk)"
        cp "${all_apks[-1]}" "$TEMP_DIR"
        cd ../ || error_exit
    done
    cd "$TEMP_DIR" || error_exit

    check_versions ./*
    adb_install_apps ./*

else
    echo "Raccoon doesn't seem to be installed. Are you sure you want to use this tool?"
    error_exit
fi
