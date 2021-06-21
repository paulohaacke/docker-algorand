FROM debian:buster-slim

ENV POSTGRES_VERSION=11
ARG INDEXER_VERSION=2.4.0
ARG INDEXER_PLATFORM=amd64

RUN apt-get update && apt-get install -y \
  gnupg2 \
  software-properties-common \
  curl \
  && curl -L https://releases.algorand.com/key.pub -o /tmp/key.pub \
  && apt-key add /tmp/key.pub \
  && add-apt-repository "deb [arch=amd64] https://releases.algorand.com/deb/ stable main" \
  && apt-get update && apt-get install -y \
  jq \
  algorand \
  postgresql-${POSTGRES_VERSION} \
  && curl -L https://github.com/algorand/indexer/releases/download/${INDEXER_VERSION}/algorand-indexer_${INDEXER_VERSION}_${INDEXER_PLATFORM}.deb -o /tmp/algorand-indexer.deb \
  && dpkg -i /tmp/algorand-indexer.deb \
  && rm /tmp/* && rm -rf /var/lib/apt/lists/*

USER root

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ADD network-example.json /etc/algorand/network.json

# Smoke test
RUN algod -v

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail -f ${ALGOD_PROC_STD_DESCRIPTORS}"]
