FROM debian:buster-slim

RUN apt-get update && apt-get install -y \
  gnupg2 \
  curl \
  software-properties-common \
  && curl -O https://releases.algorand.com/key.pub \
  && apt-key add key.pub \
  && add-apt-repository "deb [arch=amd64] https://releases.algorand.com/deb/ stable main" \
  && apt-get update \
  && apt-get install -y \
  algorand \
  && rm -rf /var/lib/apt/lists/*

# Smoke test
RUN algod -v

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ADD network-example.json /etc/algorand/network.json

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail -f ${ALGOD_PROC_STD_DESCRIPTORS}"]
