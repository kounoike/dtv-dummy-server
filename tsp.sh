#!/bin/bash

CHANNEL=$1
FILE=$2

[ -f "$FILE" ] || exit 1

BASE=$(basename "$FILE" .ts)

exec tsp \
    --add-input-stuffing  4/1 \
    -I file --infinite "$FILE" \
    -P reduce --target-bitrate 30000000 \
    -P continuity --fix \
    -P sdt --original-network-id $CHANNEL --ts-id 1 \
    -P svrename --japan --name "$BASE" --id 1 \
    -P tsrename --ts-id 1 \
    -P eitinject --file '/data/eit.xml' --japan --actual-schedule --actual-pf \
    -P timeref --eit --start system \
    -P regulate --bitrate 30000000 --packet-burst 32 \
    -P filter -n --pid 0x1fff
