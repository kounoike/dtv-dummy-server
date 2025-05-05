#!/bin/sh

set -e

mkdir -p /data/mirakc/epg

/genconfig_mirakc.sh

exec /usr/local/bin/mirakc --config $MIRAKC_CONFIG
