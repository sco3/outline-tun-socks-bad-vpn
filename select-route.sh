#!/bin/bash

# --- Configuration ---
TUN_IP="10.0.0.2"
METRIC="10"

# --- Functions ---
# Checks if the tunnel route exists.
route_exists() {
    sudo ip r | grep -q "default via ${TUN_IP}"
}

# --- Main Logic ---
if route_exists; then
    # If the route exists, show "Stop Tunnel" and "Cancel"
    RESPONSE=$(zenity --question \
        --title="Route Manager" \
        --text="Tunnel is active." \
        --ok-label="Stop Tunnel" \
        --cancel-label="Cancel")

    # Check the user's response
    if [ "$?" -eq 0 ]; then
        # "Stop Tunnel" was pressed
        sudo ip r d default via $TUN_IP
        if [ "$?" -eq 0 ]; then
            echo "Traffic is now direct."
        else
            zenity --error --text="Failed to remove the route."
        fi
    fi
else
    # If the route does not exist, show "Start Tunnel" and "Cancel"
    RESPONSE=$(zenity --question \
        --title="Route Manager" \
        --text="Tunnel is inactive." \
        --ok-label="Start Tunnel" \
        --cancel-label="Cancel")

    # Check the user's response
    if [ "$?" -eq 0 ]; then
        # "Start Tunnel" was pressed
        sudo ip r a default via $TUN_IP metric $METRIC
        if [ "$?" -eq 0 ]; then
            echo "Tunnel enabled."
        else
            zenity --error --text="Failed to add the route."
        fi
    fi
fi

exit 0