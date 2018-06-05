FROM alpine:3.7

ARG LUFI_VERSION=0.02.2

ENV GID=991 \
    UID=991 \
    SECRET=0423bab3aea2d87d5eedd9a4e8173618 \
    CONTACT=contact@domain.tld \
    MAX_FILE_SIZE=1000000000 \
    WEBROOT=/ \
    DEFAULT_DELAY=1 \
    MAX_DELAY=0 \
    ALLOW_PWD_ON_FILES=0 \
    POLICY_WHEN_FULL=warn

RUN BUILD_DEPS="build-base \
                libressl-dev \
                ca-certificates \
                git \
                tar \
                perl-dev \
                libidn-dev \
                postgresql-dev \
                wget" \
    && apk add --no-cache ${BUILD_DEPS} \
                libressl \
                perl \
                libidn \
                perl-crypt-rijndael \
                perl-test-manifest \
                perl-net-ssleay \
                tini \
                su-exec \
                postgresql-libs \
    && echo | cpan \
    && cpan install Carton \
    && git clone https://git.framasoft.org/luc/lufi.git /usr/lufi \
    && cd /usr/lufi \
# checkout a specific tag thanks to https://stackoverflow.com/a/792027/535203
    && git checkout tags/${LUFI_VERSION} -b ${LUFI_VERSION} \
    && rm -rf cpanfile.snapshot \
    && carton install \
    && apk del --no-cache ${BUILD_DEPS} \
    && rm -rf /var/cache/apk/* /root/.cpan* /usr/lufi/local/cache/* /usr/lufi/utilities
    
VOLUME /usr/lufi/files /usr/lufi/data

EXPOSE 8081

ADD startup /usr/local/bin/startup
ADD lufi.conf /usr/lufi/lufi.conf
RUN chmod +x /usr/local/bin/startup

CMD ["/usr/local/bin/startup"]
