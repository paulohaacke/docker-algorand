# Description

Algorand network private docker image.

# How to use this image

```shell
docker run -it -p8080:8080 --rm -v "$(pwd)/network-template.json":/etc/algorand/network.json" paulohaacke/algorand-private-network:2-buster-slim
```

# Environment Variables

## ALGORAND_INDEXER_NODES:

String containing node names separated by a space. Each node identified inside this variable will have an algorand-indexer tracking it and listening on port 8980 or greater.

## ALGORAND_KMD_NODES:

String containing node names separated by a space. For each node inside this string will have a KMD service exposed at port 9080 or greater.

# Ports

* Algod REST API: 8080 or greater
* Indexer REST API: 8980 or greater
* KMD Rest API: 9080 or greater

Some ports are incremented when there are more than one node configured.

