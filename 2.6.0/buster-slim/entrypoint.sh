#!/bin/bash

goal network create -r ~/net1 -n private -t /etc/algorand/network.json
goal network start -r ~/net1

ALGOD_PIDS=$(pidof algod)
TAIL_FILES=""
for pid in ${ALGOD_PIDS}; do
  TAIL_FILES="${TAIL_FILES} /proc/${pid}/fd/1 /proc/${pid}/fd/2"
done
echo "export ALGOD_PROC_STD_DESCRIPTORS=\"${TAIL_FILES}\"" >> ~/.bashrc

source ~/.bashrc
exec $(eval echo "$@")
