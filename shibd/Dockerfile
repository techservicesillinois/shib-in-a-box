ARG  TAG=latest

FROM techservicesillinois/shibd-common:$TAG as common
FROM techservicesillinois/shibd-builder:$TAG as builder

##########################################

FROM alpine

COPY --from=common /sha256sum.txt /tmp/sha256sum.common.txt
COPY --from=builder /base/sha256sum.txt /tmp/sha256sum.builder.txt

# Check for possiable race conditions during build
RUN diff /tmp/sha256sum.common.txt /tmp/sha256sum.builder.txt

##########################################

FROM common

COPY --from=builder /shibd/ /
COPY entrypoint.sh /

ENV LD_LIBRARY_PATH=/opt/shibboleth/lib64 \
    SHIBSP_CONFIG=/etc/shibboleth/shibboleth2.xml \
    LANG=C

VOLUME ["/etc/shibboleth", "/var/shib-keys"]

USER shibd
EXPOSE 1600

ENTRYPOINT [ "/entrypoint.sh" ]
