#!/bin/bash

# Source utilities
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SOURCE_DIR/utils.sh"

ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
# Bump to the newest build listed in
# https://dl.google.com/android/repository/repository2-3.xml when needed;
# sdkmanager keeps itself current after that.
CMDLINE_TOOLS_BUILD=16111833

echo "Installing Android SDK into $ANDROID_HOME..."

install_package jdk17-openjdk android-tools android-udev unzip

# The emulator needs /dev/kvm
ensure_group kvm

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
SDKMANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"

# Bootstrap sdkmanager from Google's zip; it unpacks as cmdline-tools/
if [ ! -x "$SDKMANAGER" ]; then
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/tools.zip" \
        "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_BUILD}_latest.zip"
    unzip -q "$tmp/tools.zip" -d "$tmp"
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    mv "$tmp/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
    rm -rf "$tmp"
fi

yes | "$SDKMANAGER" --licenses > /dev/null
"$SDKMANAGER" \
    "platform-tools" \
    "emulator" \
    "platforms;android-35" \
    "platforms;android-36" \
    "build-tools;35.0.0" \
    "build-tools;36.0.0" \
    "ndk;27.1.12297006" \
    "cmake;3.22.1" \
    "system-images;android-36;google_apis;x86_64"

echo "Android SDK installed successfully!"
