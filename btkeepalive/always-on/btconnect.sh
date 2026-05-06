#!/bin/bash

# Always ON

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

# Minimum battery level to attempt reconnection and defer suspend.
# Below this threshold and not charging, the Kindle is allowed to sleep
# and reconnection is skipped. Adjust this value in btkeepalive.conf.
# THRESHOLD is loaded from btkeepalive.conf

echo "$(date) - ipod mode started" >>"$LOGFILE"

printf 'com.lab126.powerd\ncom.lab126.btfd' | lipc-wait-event -l -m readyToSuspend,Disconnect_Result 2>/dev/null | while read EVENT; do

  case "$EVENT" in

  *"readyToSuspend"*)
    BATT=$(lipc-get-prop com.lab126.powerd battLevel 2>/dev/null)
    CHARGING=$(lipc-get-prop com.lab126.powerd isCharging 2>/dev/null)
    if [ "$CHARGING" -eq 1 ] || [ "$BATT" -ge "$THRESHOLD" ]; then
      lipc-set-prop com.lab126.powerd deferSuspend 600
      echo "$(date) - readyToSuspend intercepted, deferSuspend set (Batt: $BATT%, Charging: $CHARGING)" >>"$LOGFILE"
    else
      echo "$(date) - low battery ($BATT%), allowing sleep" >>"$LOGFILE"
    fi
    ;;

  *"Disconnect_Result"*)
    BATT=$(lipc-get-prop com.lab126.powerd battLevel 2>/dev/null)
    CHARGING=$(lipc-get-prop com.lab126.powerd isCharging 2>/dev/null)
    if [ "$CHARGING" -eq 1 ] || [ "$BATT" -ge "$THRESHOLD" ]; then
      echo "$(date) - disconnection detected, reconnecting (Batt: $BATT%, Charging: $CHARGING)" >>"$LOGFILE"
      sleep 2
      lipc-set-prop com.lab126.btfd Connect "$MAC"
    else
      echo "$(date) - low battery ($BATT%), skipping reconnect" >>"$LOGFILE"
    fi
    ;;

  esac
done
