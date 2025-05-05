#!/bin/bash

set -e

DATADIR=${DATADIR:-/data}
MIRAKC_CONFIG=${MIRAKC_CONFIG:-/etc/mirakc/config.yaml}
UPLINK_URL=${UPLINK_URL}

echo "GENERATING CONFIGURATION FILE"
echo "  config:${MIRAKC_CONFIG}"
echo "  uplink:${UPLINK_URL}"

mapfile -t FILES < <(ls -1 ${DATADIR}/*.ts 2>/dev/null)

cat - <<EOT > $MIRAKC_CONFIG
server:
  addrs:
    - http: 0.0.0.0:40772

epg:
  cache-dir: /data/mirakc/epg

channels:
EOT

for i in "${!FILES[@]}"; do
  F="${FILES[i]}"
  echo "  - { name: '$(basename $F .ts)', type: SKY, channel: $i, extra-args: '$F' }"  >> $MIRAKC_CONFIG
done

echo "" >> $MIRAKC_CONFIG

# エスケープシーケンスでの書き方分からない・・・
BACK_IFS=$IFS
IFS='
'

if [ "z$UPLINK_URL" != "z" ]; then
  SERVICES=$(curl -s "${UPLINK_URL}/api/services" | jq -r '.[] | select(.channel.type == "GR") | "{ name: " + .name + ", type: " + .channel.type + ", channel: \"" + .channel.channel + "\" }"')

  for S in $SERVICES; do
    echo "  - $S" >> $MIRAKC_CONFIG
  done
fi

echo "" >> $MIRAKC_CONFIG
echo "tuners:" >> $MIRAKC_CONFIG

for x in $(seq 1 3); do
  echo "  - { name: dummy$x , types: [SKY] , command: '/tsp.sh \"{{{channel}}}\" \"{{{extra_args}}}\"' }" >> $MIRAKC_CONFIG
done

if [ "z$UPLINK_URL" != "z" ]; then
  curl_command="curl -s ${UPLINK_URL}/api/channels/{{{channel_type}}}/{{{channel}}}/stream?decode=1"
  for x in $(seq 1 3); do
    echo "  - { name: upstream$x , types: [GR] , command: '${curl_command}' }" >> $MIRAKC_CONFIG
  done
fi

# # EPGちゃんと埋め込めないとmirakcが死ぬのでスキャンを停止しておく
# cat - <<EOT >> $MIRAKC_CONFIG

# jobs:
#   update-schedules:
#     disabled: true
# EOT


echo "GENERATED!"
cat $MIRAKC_CONFIG
