#!/bin/bash

set -e

DATADIR=${DATADIR:-/data}
MIRAKURUN_CONFIG_DIR=${MIRAKURUN_CONFIG_DIR:-/app-config}
UPLINK_URL=${UPLINK_URL}

echo "GENERATING CONFIGURATION FILE"
echo "  config_dir:${MIRAKURUN_CONFIG_DIR}"
echo "  uplink:${UPLINK_URL}"

mkdir -p $MIRAKURUN_CONFIG_DIR
rm -f $MIRAKURUN_CONFIG_DIR/*.yml

mapfile -t FILES < <(ls -1 ${DATADIR}/*.ts 2>/dev/null)

cat - <<EOT > $MIRAKURUN_CONFIG_DIR/server.yml
logLevel: 3
path: /var/run/mirakurun.sock
port: 40772
EOT

for i in "${!FILES[@]}"; do
  F="${FILES[i]}"
  echo "  - { name: '$(basename $F .ts)', type: SKY, channel: '$i', commandVars: { filename: '$F' }, isDisabled: false }"  >> $MIRAKURUN_CONFIG_DIR/channels.yml
done


# エスケープシーケンスでの書き方分からない・・・
BACK_IFS=$IFS
IFS='
'

if [ "z$UPLINK_URL" != "z" ]; then
  SERVICES=$(curl -s "${UPLINK_URL}/api/services" | jq -r '.[] | select(.channel.type == "GR") | "{ name: " + .name + ", type: " + .channel.type + ", channel: \"" + .channel.channel + "\", commandVars: { channel_type: GR }, isDisabled: false }"')

  for S in $SERVICES; do
    echo "  - $S" >> $MIRAKURUN_CONFIG_DIR/channels.yml
  done
fi

for x in $(seq 1 3); do
  echo "  - { name: dummy$x , types: [SKY] , command: '/tsp.sh \"<channel>\" \"<filename>\"' }" >> $MIRAKURUN_CONFIG_DIR/tuners.yml
done

if [ "z$UPLINK_URL" != "z" ]; then
  curl_command="curl -s ${UPLINK_URL}/api/channels/<channel_type>/<channel>/stream?decode=1"
  for x in $(seq 1 3); do
    echo "  - { name: upstream$x , types: [GR] , command: '${curl_command}' }" >> $MIRAKURUN_CONFIG_DIR/tuners.yml
  done
fi

echo "GENERATED!"
