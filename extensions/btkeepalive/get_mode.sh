#!/bin/bash
# Show current BT Keepalive mode via Pillow notification

CONFIG_FILE="/mnt/us/btkeepalive/config.conf"

if [ ! -f "$CONFIG_FILE" ]; then
  lipc-set-prop com.lab126.pillow pillowAlert '{"clientParams":{"alertId":"appAlert1","show":true,"customStrings":[{"matchStr":"alertTitle","replaceStr":"BT Keepalive"},{"matchStr":"alertText","replaceStr":"Config file missing. Please run setup first."}]}}'
  exit 1
fi

MODE=$(tr -d '[:space:]' <"$CONFIG_FILE")
case "$MODE" in
"reading")
  MSG="Reading Mode"
  ;;
"always-on")
  MSG="Always On Mode"
  ;;
"default")
  MSG="Default (Disabled)"
  ;;
*)
  MSG="Unknown mode: $MODE"
  ;;
esac

lipc-set-prop com.lab126.pillow pillowAlert '{"clientParams":{"alertId":"appAlert1","show":true,"customStrings":[{"matchStr":"alertTitle","replaceStr":"BT Keepalive"},{"matchStr":"alertText","replaceStr":"Current Mode: '"$MSG"'"}]}}'
