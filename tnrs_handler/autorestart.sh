#! /bin/env bash
RES=$(curl -s -m 180 localhost/status)
echo $RES
if [ -z "$RES" ]; then
cd /opt/TNRastic/tnrs_handler
./restart.sh
echo $(date) *autorestart* 1>&2
fi
