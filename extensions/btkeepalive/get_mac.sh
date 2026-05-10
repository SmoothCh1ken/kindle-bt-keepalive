#!/bin/sh

# Get paired Bluetooth device MAC address and show via Pillow notification

MAC=""
# Parse bt_config.conf - look for section headers like [XX:XX:XX:XX:XX:XX]
# These are paired device MACs. Skip [Adapter] and [Info] sections.
if [ -f /var/local/zbluetooth/bt_config.conf ]; then
  MAC=$(grep -E '^\[[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}\]$' /var/local/zbluetooth/bt_config.conf 2>/dev/null | grep -v '\[Adapter\]' | head -1 | tr -d '[]')
fi

# Fallback: ConnectedDevices
if [ -z "$MAC" ]; then
  MAC=$(lipc-get-prop com.lab126.btfd ConnectedDevices 2>/dev/null | grep -oE '([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}' | head -1)
fi

# Validate and notify
if [ -n "$MAC" ] && echo "$MAC" | grep -qE '^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$'; then
  lipc-set-prop com.lab126.pillow pillowAlert '{"clientParams":{"alertId":"appAlert1","show":true,"customStrings":[{"matchStr":"alertTitle","replaceStr":"BT Keepalive"},{"matchStr":"alertText","replaceStr":"Device MAC: '"$MAC"'"}]}}'
else
  lipc-set-prop com.lab126.pillow pillowAlert '{"clientParams":{"alertId":"appAlert1","show":true,"customStrings":[{"matchStr":"alertTitle","replaceStr":"BT Keepalive"},{"matchStr":"alertText","replaceStr":"No paired device found. Pair via Settings -> Bluetooth first."}]}}'
fi
