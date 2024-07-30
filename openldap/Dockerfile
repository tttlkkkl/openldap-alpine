FROM alpine:3.20
LABEL MAINTAINER="tttlkkkl <tttlkkkl@aliyun.com>"
ENV TZ "Asia/Shanghai"
ENV TERM xterm

RUN echo 'http://mirrors.aliyun.com/alpine/v3.20/main/' > /etc/apk/repositories && \
    echo 'http://mirrors.aliyun.com/alpine/v3.20/community/' >> /etc/apk/repositories
ENV ORGANISATION_NAME "Example Ltd"
ENV SUFFIX "dc=example,dc=com"
ENV ROOT_USER "admin"
ENV ROOT_PW "password"
ENV USER_UID "pgarrett"
ENV USER_GIVEN_NAME "Phill"
ENV USER_SURNAME "Garrett"
ENV USER_EMAIL "pgarrett@example.com"
ENV LOG_LEVEL "stats"
ENV CA_DIR "/etc/ssl/certs"
RUN apk add --update --no-cache openldap-back-mdb openldap openssl openldap-overlay-memberof openldap-clients && \
    mkdir -p /run/openldap /var/lib/openldap/openldap-data

COPY scripts/* /etc/openldap/
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
EXPOSE 389
EXPOSE 636

VOLUME ["/ldif", "/var/lib/openldap/openldap-data"]

ENTRYPOINT ["/docker-entrypoint.sh"]
