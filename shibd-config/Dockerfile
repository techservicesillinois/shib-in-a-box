ARG  TAG=latest

FROM techservicesillinois/shibd-base:$TAG as base
FROM techservicesillinois/shibd-builder:$TAG as builder

##########################################

FROM alpine

COPY --from=base /sha256sum.txt /tmp/sha256sum.base.txt
COPY --from=builder /base/sha256sum.txt /tmp/sha256sum.builder.txt

# Check for possiable race conditions during build
RUN diff /tmp/sha256sum.base.txt /tmp/sha256sum.builder.txt

##########################################

FROM golang:alpine as golang

ENV SRC=get-shib-keys

RUN apk update && apk add git make upx

COPY $SRC/*.go $SRC/Makefile $GOPATH/src/
WORKDIR $GOPATH/src
RUN make deps && make && make compress

####################################

FROM alpine as itrust

ENV DISCOVERY_SVC_URL https://discovery.itrust.illinois.edu 

RUN mkdir -p /tmp/shibboleth \
    && wget -qO /tmp/shibboleth/itrust.pem \
       "${DISCOVERY_SVC_URL}/itrust-certs/itrust.pem" \
    && wget -qO /tmp/shibboleth/itrust-metadata.xml \
       "${DISCOVERY_SVC_URL}/itrust-metadata/itrust-metadata.xml"

####################################

FROM base

ARG TAG

ENV SHIBSP_CONFIG=/etc/shibboleth/shibboleth2.xml \
    SHIBSP_CONFIG_TEMPLATE=/etc/shibboleth/shibboleth2.template \
    SHIBD_LOG=/etc/shibboleth/shibd.logger \
    MOD_SHIB_LOG=/etc/shibboleth/native.logger \
    SHIBD_LOG_LEVEL=INFO \
    MOD_SHIB_LOG_LEVEL=INFO

COPY --from=builder /shibd-config/ /
COPY --from=golang /go/src/get-shib-keys /usr/local/bin/
COPY --chown=shibd:shibd --from=itrust /tmp/shibboleth/ /etc/shibboleth/

COPY /root/entrypoint.sh /
COPY --chown=shibd:shibd /root/etc/shibboleth/ /etc/shibboleth/

USER shibd

VOLUME ["/etc/shibboleth"]

ENTRYPOINT [ "/entrypoint.sh" ]
