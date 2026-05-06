#!/bin/bash

# Reading Mode

# Load configuration
CONFIG_FILE="/mnt/us/btkeepalive/btkeepalive.conf"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  lipc-set-prop com.lab126.pillow pillowAlert "{\"clientParams\":{\"alertId\":\"appAlert1\",\"show\":true,\"customStrings\":[{\"matchStr\":\"alertTitle\",\"replaceStr\":\"BT Keepalive\"},{\"matchStr\":\"alertText\",\"replaceStr\":\"Config file missing. Copy btkeepalive.conf.example to btkeepalive.conf\"}]}}"
  exit 1
fi

# Ensure log directory exists
mkdir -p "$(dirname "$LOGFILE")"

echo "$(date) - script started" >>"$LOGFILE"

# Listen for all Bluetooth events. Using "*" instead of "Disconnect_Result"
# allows the script to intercept the connection silently — before the device
# actually disconnects — so headphones never play the disconnect sound.
lipc-wait-event -m com.lab126.btfd "*" | while read EVENT; do
  if [[ "$EVENT" == *"Disconnect_Result"* ]]; then
    echo "$(date) - disconnection detected, reconnecting" >>"$LOGFILE"
    sleep 2
    lipc-set-prop com.lab126.btfd Connect "$MAC"
    echo "$(date) - Connect command sent to $MAC" >>"$LOGFILE"
  fi
done
