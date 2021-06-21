#!/bin/bash

# Initialize Database
pg_ctlcluster ${POSTGRES_VERSION} main start \
  && runuser -u postgres -- psql --command "CREATE USER algorand_indexer WITH SUPERUSER PASSWORD 'indexer';"

# Create network
goal network create -r ~/net1 -n private -t /etc/algorand/network.json

# Change config.json to include "EndpointAddress"
port_index=8080
for config_file in ~/net1/**/config.json; do
  #sed -i "s/127\.0\.0\.1\:0/0\.0\.0\.0:${port_index}/g" ${config_file} && ((port_index++))
  echo "$(cat $config_file | jq --arg ENDPOINT "0.0.0.0:${port_index}" '. + {EndpointAddress: $ENDPOINT}')" > ${config_file}
  ((port_index++))
done

# Start Network
goal network start -r ~/net1

# Start Indexer
INDEXER_NODES_STRINGS="${ALGORAND_INDEXER_NODES:-Participant}"
IFS=', ' read -r -a INDEXER_NODES_ARRAY <<< "$INDEXER_NODES_STRINGS"
for i in "${!INDEXER_NODES_ARRAY[@]}"; do 
  node=${INDEXER_NODES_ARRAY[$i]}
  node_dir=~/net1/${node}/
  db_name="$(echo $node | tr '[:upper:]' '[:lower:]')_ledgerdb"
  (runuser -u postgres -- createdb -O algorand_indexer ${db_name}) \
  && algorand-indexer daemon -S ":$((i+8980))" -P "host=localhost port=5432 user=algorand_indexer password=indexer dbname=${db_name} sslmode=disable" -d ${node_dir} &
done

# Start and Expose KMD
KMD_NODES_STRINGS="${ALGORAND_KMD_NODES:-Participant}"
IFS=', ' read -r -a KMD_NODES_ARRAY <<< "$KMD_NODES_STRINGS"
for i in "${!KMD_NODES_ARRAY[@]}"; do 
  node=${KMD_NODES_ARRAY[$i]}
  node_dir=~/net1/${node}
  echo "{\"address\": \"0.0.0.0:$((i+9080))\"}" > ${node_dir}/kmd-v0.5/kmd_config.json
  goal kmd start -d ${node_dir}
done

# Get stdout and stderr output files
ALGOD_PIDS="$(pidof algod algorand-indexer)"
TAIL_FILES="/var/log/postgresql/*.log"
for pid in ${ALGOD_PIDS}; do
  TAIL_FILES="${TAIL_FILES} /proc/${pid}/fd/1 /proc/${pid}/fd/2"
done
echo "export ALGOD_PROC_STD_DESCRIPTORS=\"${TAIL_FILES}\"" >> ~/.bashrc

source ~/.bashrc
exec $(eval echo "$@")
