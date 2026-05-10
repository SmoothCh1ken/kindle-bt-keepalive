#!/bin/sh
# Wrapper script to start the correct mode on boot via Upstart.
# Reads mode from /mnt/us/btkeepalive/config.conf and execs the
# appropriate btconnect.sh. Called exclusively by the Upstart job.

BASE_DIR="/mnt/us/btkeepalive"
CONFIG_FILE="$BASE_DIR/config.conf"
READING_SCRIPT="$BASE_DIR/reading-mode/btconnect.sh"
ALWAYS_ON_SCRIPT="$BASE_DIR/always-on/btconnect.sh"
LOGFILE="$BASE_DIR/log/wrapper.log"

# Ensure log directory exists
mkdir -p "$BASE_DIR/log"
echo "$(date) - [wrapper] started" >> "$LOGFILE"

# Read mode from config; default to disabled if file missing or value unknown
if [ -f "$CONFIG_FILE" ]; then
  read -r MODE < "$CONFIG_FILE"
else
  MODE="default"
fi

echo "$(date) - [wrapper] mode=$MODE" >> "$LOGFILE"

case "$MODE" in
  "reading")
    exec /bin/sh "$READING_SCRIPT"
    ;;
  "always-on")
    exec /bin/sh "$ALWAYS_ON_SCRIPT"
    ;;
  *)
    echo "$(date) - [wrapper] default mode, entering idle loop" >> "$LOGFILE"
    while :; do sleep 60; done
    ;;
esac
