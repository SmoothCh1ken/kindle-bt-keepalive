#!/bin/bash
# Default (Disable) Mode:
#   1. Writes "default" to config.conf (persists across reboots)
#   2. Stops Upstart service FIRST (prevents respawn fighting pkill)
#   3. Kills any leftover processes
#   4. Removes the Upstart job file (rw → delete → ro), clean system restore
#   5. Shows a Pillow notification to confirm

BASE_DIR="/mnt/us/btkeepalive"
CONFIG_FILE="$BASE_DIR/config.conf"
UPSTART_CONF="/etc/upstart/btkeepalive.conf"
LOGFILE="$BASE_DIR/log/wrapper.log"

# Ensure log dir exists
mkdir -p "$BASE_DIR/log"

# --- 1. Persist mode ---
echo "default" > "$CONFIG_FILE"
echo "$(date) - [set_default] config set to: default" >> "$LOGFILE"

# --- 2. Stop Upstart service BEFORE pkill ---
# This prevents Upstart respawn from restarting the process we're about to kill
initctl stop btkeepalive 2>/dev/null || true
sleep 1

# --- 3. Kill any leftover processes ---
pkill -f "btconnect.sh" 2>/dev/null || true
pkill -f "btkeepalive_wrapper.sh" 2>/dev/null || true
echo "$(date) - [set_default] all keepalive processes stopped" >> "$LOGFILE"

# --- 4. Remove Upstart job and restore read-only root ---
# The Upstart conf is on the system partition (read-only by default).
# We temporarily remount rw, delete the file, then restore ro.
if [ -f "$UPSTART_CONF" ]; then
    mntroot rw 2>/dev/null
    rm -f "$UPSTART_CONF"
    initctl reload-configuration 2>/dev/null || true
    mntroot ro 2>/dev/null
    echo "$(date) - [set_default] Upstart job removed, root restored to ro" >> "$LOGFILE"
else
    echo "$(date) - [set_default] Upstart job not present, nothing to remove" >> "$LOGFILE"
fi

# --- 5. Notify user ---
lipc-set-prop com.lab126.pillow pillowAlert \
  '{"clientParams":{"alertId":"appAlert1","show":true,"customStrings":[{"matchStr":"alertTitle","replaceStr":"BT Keepalive"},{"matchStr":"alertText","replaceStr":"Disabled (default mode)"}]}}'
