FROM golang:1.11-alpine as builder

ENV SRC=get-sealer-keys

RUN apk update && apk add git ca-certificates make upx
RUN addgroup -g 998 shibd
RUN adduser -h /var/run/shibboleth -g "Shibboleth SP daemon" -u 999 -S -G shibd shibd

COPY $SRC/*.go $SRC/Makefile $GOPATH/src/
WORKDIR $GOPATH/src
RUN make deps && make && make compress
##############################################################

FROM golang:1.11-alpine as healthcheck-builder

ENV SRC=healthcheck

RUN apk update && apk add git make upx

COPY $SRC/*.go $SRC/Makefile $GOPATH/src/
WORKDIR $GOPATH/src
RUN make deps && make && make compress
##############################################################

FROM scratch

ENV KEYS=/var/shib-keys/keys \
    SCHEDULE="@midnight"

# create /var/shib-keys with correct perms
ADD cron.tar.gz /
VOLUME ["/var/shib-keys/"]

COPY --from=builder /etc/passwd /etc/group /etc/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/src/get-sealer-keys /
COPY --from=healthcheck-builder /go/src/healthcheck /

USER shibd

HEALTHCHECK CMD ["/healthcheck"]

ENTRYPOINT ["/get-sealer-keys"]
