#!/bin/bash

SERVICE_LABEL="com.aitkn.skedaiuserserver"
INSTALL_DIR="/usr/local/bin"
PLIST_FILE="/Library/LaunchAgents/$SERVICE_LABEL.plist"

# stop service if it is running
if [ -f "$PLIST_FILE" ]; then
    echo "Service plist exists. Checking if the service is running..."

    if launchctl list | grep -q "$SERVICE_LABEL"; then
        echo "Service is running. Stopping the service..."
        launchctl unload "$PLIST_FILE"
    else
        echo "Service is not running."
    fi

    echo "Removing existing service plist..."
    rm -f "$PLIST_FILE"
fi

# remove existing files in the installation location
echo "Checking and removing existing files in $INSTALL_DIR..."
rm -f "$INSTALL_DIR/userServer_mac"
rm -f "$INSTALL_DIR/skedaiSatRunner_mac"
rm -f "$INSTALL_DIR/authenticator_mac"

echo "Cleanup completed."
