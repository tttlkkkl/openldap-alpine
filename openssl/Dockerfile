FROM alpine:3.13
LABEL MAINTAINER="tttlkkkl <tttlkkkl@aliyun.com>"
ENV TZ "Asia/Shanghai"
ENV TERM xterm

RUN echo 'http://mirrors.aliyun.com/alpine/v3.13/main/' > /etc/apk/repositories && \
    echo 'http://mirrors.aliyun.com/alpine/v3.13/community/' >> /etc/apk/repositories

# default variables
ENV COUNTY "CN"
ENV STATE "dn AD Special Certificate"
ENV LOCATION "shenzhen"
ENV ORGANISATION "dn"
ENV ROOT_CN "root"
ENV ISSUER_CN "lihuaio"
ENV PUBLIC_CN "*.lihuaio.com"
ENV ROOT_NAME "root"
ENV ISSUER_NAME "lihuaio"
ENV PUBLIC_NAME "public"
ENV RSA_KEY_NUMBITS "2048"
ENV DAYS "365"
ENV KEYSTORE_NAME "keystore"
ENV KEYSTORE_PASS "changeit"
ENV CERT_DIR "/etc/ssl/certs"

# install openssl
RUN apk add --update openssl && \
    rm -rf /var/cache/apk/*

COPY *.ext /
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
VOLUME ["$CERT_DIR"]
ENTRYPOINT ["/docker-entrypoint.sh"]
