#!/bin/sh

# Always-On

CONFIG_FILE="/mnt/us/btkeepalive/btkeepalive.conf"
if [ -f "$CONFIG_FILE" ]; then
  . "$CONFIG_FILE"
else
  lipc-set-prop com.lab126.pillow pillowAlert '{"clientParams":{"alertId":"appAlert1","show":true,"customStrings":[{"matchStr":"alertTitle","replaceStr":"BT Keepalive"},{"matchStr":"alertText","replaceStr":"Config file missing. Copy btkeepalive.conf to /mnt/us/btkeepalive/"}]}}'
  exit 1
fi

mkdir -p "$(dirname "$LOGFILE")"

trap 'lipc-set-prop com.lab126.powerd deferSuspend 0 2>/dev/null; echo "$(date) - sleep prevention released (trap)" >> "$LOGFILE"' EXIT

echo "$(date) - always-on mode started" >> "$LOGFILE"

# NOTA TECNICA: en vez de esperar un nombre de evento especifico de
# "Disconnect_Result" (asumido de la pila Bluedroid, 11th gen+ y que
# no existe/no esta documentado en la pila Broadcom BSA de 8th-10th gen),
# usamos CUALQUIER evento de btfd como disparador y verificamos el estado
# real via la propiedad documentada ListConnected. Esto funciona sin
# importar el nombre interno del evento, en ambas pilas Bluetooth.
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

lipc-set-prop com.lab126.powerd deferSuspend 86400 2>/dev/null
echo "$(date) - sleep prevention set (24h)" >> "$LOGFILE"

while :; do
  BATT=$(lipc-get-prop com.lab126.powerd battLevel 2>/dev/null)
  CHARGING=$(lipc-get-prop com.lab126.powerd isCharging 2>/dev/null)
  if [ "$BATT" -lt "${THRESHOLD:-20}" ] 2>/dev/null && [ "$CHARGING" != "1" ] 2>/dev/null; then
    lipc-set-prop com.lab126.powerd deferSuspend 0 2>/dev/null
    echo "$(date) - battery at ${BATT}%, sleep prevention removed, exiting" >> "$LOGFILE"
    exit 0
  fi
  # Red de seguridad adicional: revisa la conexion cada ciclo, no solo por evento
  if ! is_connected; then
    lipc-set-prop com.lab126.btfd Connect "$MAC" 2>/dev/null
    echo "$(date) - chequeo periodico: desconectado, reconexion intentada" >> "$LOGFILE"
  fi
  sleep 600
done
