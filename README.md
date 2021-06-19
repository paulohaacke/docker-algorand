# Description

Algorand network private docker image.

# How to use this image

```shell
docker run -it --rm -v "$(pwd)/network-template.json":/etc/algorand/network.json" paulohaacke/algorand-private-network:2-buster-slim
```

# Issues

A field called "EndpointAddress" could be added to a Node inside the network.json template in order to change the IP address algod is listening on.
