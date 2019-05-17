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

FROM base

COPY --from=builder /common/ /
