ARG  TAG=latest

FROM techservicesillinois/shibd-builder:${TAG} as builder

###########

FROM scratch

COPY --from=builder /base/ /
