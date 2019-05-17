FROM centos:7 as builder

COPY shib.repo /etc/yum.repos.d/

# TODO Should we keep the default httpd/shibd config files at all?
#       Probably not...
RUN yum -y install \
       httpd \
       shibboleth \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /etc/shibboleth/ \
    && rm /etc/httpd/conf/httpd.conf \
    && rm /etc/httpd/conf.d/*

COPY dereflinks /usr/local/bin/
COPY make_layers.sh manifest.* /tmp/

WORKDIR /tmp
RUN ./make_layers.sh

######################################

FROM scratch

MAINTAINER Technology Services, University of Illinois Urbana

COPY --from=builder /tmp/fakeroot/ /
