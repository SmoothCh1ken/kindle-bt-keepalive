#!/bin/sh

# Get paired Bluetooth device MAC addresses and show via Pillow notification.
# Displays up to the last 3 paired devices (most recently paired).
#
# NOTA TECNICA: en Kindles 8th-10th gen (chip NXP + radio Broadcom BCM4343)
# el stack Bluetooth es Broadcom BSA (bsa_server sobre UART), sin archivo de
# config accesible ni en /var/local/zbluetooth ni en /opt/zbluetooth (esas
# rutas solo existen en 11th gen+ con pila Bluedroid/btmanagerd). En vez de
# leer un archivo, se consulta la propiedad LIPC "ListPaired" de
# com.lab126.btfd, que es la capa de abstraccion comun a ambos stacks.

RAW=$(lipc-get-prop com.lab126.btfd ListPaired 2>/dev/null)

# Extrae hasta 3 MACs unicas del hash devuelto por LIPC
LIST=""
MACS=$(echo "$RAW" | grep -oE '([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}' | sort -u | tail -3)

for MAC in $MACS; do
  # Intenta extraer un nombre asociado si aparece cerca del MAC en el hash
  NAME=$(echo "$RAW" | grep -A 3 "$MAC" | grep -oE '"[A-Za-z0-9 _.-]{2,35}"' | head -1 | tr -d '"')
  if [ -n "$NAME" ]; then
    LIST="$LIST$MAC ($NAME)\n"
  else
    LIST="$LIST$MAC\n"
  fi
done

if [ -z "$LIST" ]; then
  lipc-set-prop com.lab126.pillow pillowAlert \
    '{"clientParams":{"alertId":"appAlert1","show":true,"customStrings":[{"matchStr":"alertTitle","replaceStr":"BT Keepalive"},{"matchStr":"alertText","replaceStr":"No paired devices found. Pair via Settings -> Bluetooth first."}]}}'
else
  lipc-set-prop com.lab126.pillow pillowAlert \
    '{"clientParams":{"alertId":"appAlert1","show":true,"customStrings":[{"matchStr":"alertTitle","replaceStr":"BT Keepalive"},{"matchStr":"alertText","replaceStr":"Paired devices:\n'"$LIST"'"}]}}'
fi
