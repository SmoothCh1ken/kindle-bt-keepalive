#!/bin/sh

# Reading Mode

CONFIG_FILE="/mnt/us/btkeepalive/btkeepalive.conf"
if [ -f "$CONFIG_FILE" ]; then
  . "$CONFIG_FILE"
else
  lipc-set-prop com.lab126.pillow pillowAlert '{"clientParams":{"alertId":"appAlert1","show":true,"customStrings":[{"matchStr":"alertTitle","replaceStr":"BT Keepalive"},{"matchStr":"alertText","replaceStr":"Config file missing. Copy btkeepalive.conf to /mnt/us/btkeepalive/"}]}}'
  exit 1
fi

mkdir -p "$(dirname "$LOGFILE")"

echo "$(date) - reading mode started" >> "$LOGFILE"

# NOTA TECNICA: ver comentario en always-on/btconnect.sh - se reemplaza la
# deteccion por nombre de evento asumido ("Disconnect_Result") por una
# verificacion del estado real via la propiedad documentada ListConnected,
# valida tanto en la pila Broadcom BSA (8th-10th gen) como en Bluedroid.
is_connected() {
  lipc-get-prop com.lab126.btfd ListConnected 2>/dev/null | grep -qi "$MAC"
}

lipc-wait-event -m com.lab126.btfd "*" | while read EVENT; do
  if ! is_connected; then
    lipc-set-prop com.lab126.btfd Connect "$MAC" 2>/dev/null
    echo "$(date) - desconexion detectada (evento: $EVENT), reconectado" >> "$LOGFILE"
  fi
done &

lipc-set-prop com.lab126.btfd Connect "$MAC" 2>/dev/null

wait $!
