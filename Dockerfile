ARG CONFD_VERSION=0.14.0
FROM gzigzigzeo/docker-download-confd as confd

# ===============================================

FROM debian:jessie AS build

ENV STELLAR_CORE_VERSION "0.6.3-391-708237b0"
ENV STELLAR_DEB_URL "https://s3.amazonaws.com/stellar.org/releases/stellar-core/stellar-core-${STELLAR_CORE_VERSION}_amd64.deb"

RUN apt-get update && apt-get install -y curl git libpq-dev libsqlite3-dev libsasl2-dev postgresql-client vim zlib1g-dev && apt-get clean

# Installation
RUN curl -o stellar-core.deb $STELLAR_DEB_URL \
 && dpkg -i stellar-core.deb \
 && rm stellar-core.deb

# ===============================================

FROM debian:jessie

MAINTAINER Viktor Sokolov <gzigzigzeo@evilmartians.com>

ENV STELLAR_CORE_DATABASE_URL "user=gzigzigzeo host=docker.for.mac.localhost dbname=core"
ENV STELLAR_CORE_PEER_PORT 11625
ENV STELLAR_CORE_HTTP_PORT 11626

# Dependencies
RUN apt-get update && apt-get -y install curl ca-certificates postgresql-client bash && apt-get clean

# Confd
COPY --from=confd /usr/local/bin/confd /usr/local/bin/confd
COPY templates /etc/confd/templates/
COPY conf.d /etc/confd/conf.d/

# Installation
COPY --from=build /usr/local/bin/stellar-core /usr/local/bin/stellar-core
RUN mkdir -p /var/stellar/core/testnet && mkdir -p /var/stellar/core/pubnet

# Scripts
COPY docker_healthcheck.sh /
RUN chmod +x /docker_healthcheck.sh

COPY docker_entrypoint.sh /
RUN chmod +x /docker_entrypoint.sh

ENTRYPOINT ["/docker_entrypoint.sh"]
CMD ["stellar-core", "--conf", "/etc/stellar-core.cfg"]
EXPOSE ${STELLAR_CORE_HTTP_PORT} ${STELLAR_CORE_PEER_PORT}

HEALTHCHECK CMD ["/docker_healthcheck.sh"]
