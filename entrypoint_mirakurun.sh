#!/bin/sh

set -e

export DISABLE_PCSCD=1
export DISABLE_B25_TEST=1

mkdir -p /data/mirakurun
ln -s /data/mirakurun /app-data 

/genconfig_mirakurun.sh

cd /app
exec /app/docker/container-init.sh
