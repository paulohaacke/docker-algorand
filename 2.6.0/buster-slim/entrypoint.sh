#!/bin/bash

NODE_ENDPOINT_STRINGS=$(jq '.Nodes[] | select(.EndpointAddress!=null) | .Name,.EndpointAddress' /etc/algorand/network.json | tr '\r\n' ' ')
IFS=', ' read -r -a NODE_ENDPOINT_ARRAY <<< "$NODE_ENDPOINT_STRINGS"

for i in "${!NODE_ENDPOINT_ARRAY[@]}"; do 
  if [ $((i%2)) -eq 0 ]; then
    NODE_CONFIG_FILE=$(eval echo "~/net1/${NODE_ENDPOINT_ARRAY[$i]}/config.json")
  else
    ENDPOINT=$(eval echo ${NODE_ENDPOINT_ARRAY[$i]})
    echo "$(cat $NODE_CONFIG_FILE | jq --arg ENDPOINT $ENDPOINT '. + {EndpointAddress: $ENDPOINT}')" > ${NODE_CONFIG_FILE}
  fi
done

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
