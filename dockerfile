FROM debian:buster-slim

# Переменные окружения конфигурации со значениями по умолчанию
ENV DATA_DIR="/opt/openldap/bootstrap/data"
ENV CONFIG_DIR="/opt/openldap/bootstrap/config"
ENV LDAP_DOMAIN=planetexpress.com
ENV LDAP_ORGANISATION="Planet Express, Inc."
ENV LDAP_BINDDN="cn=admin,dc=eden,dc=local"
ENV LDAP_SECRET=GoodNewsEveryone
ENV LDAP_CA_CERT="/etc/ldap/ssl/fullchain.crt"
ENV LDAP_SSL_KEY="/etc/ldap/ssl/ldap.key"
ENV LDAP_SSL_CERT="/etc/ldap/ssl/ldap.crt"
ENV LDAP_FORCE_STARTTLS="false"

# Install slapd and requirements
RUN apt-get update \
	&& apt-get dist-upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get \
        install -y --no-install-recommends \
            slapd \
            ldap-utils \
            openssl \
            ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /etc/ldap/ssl /bootstrap

# ADD rootfs files
ADD ./rootfs /

VOLUME ["/etc/ldap/slapd.d", "/etc/ldap/ssl", "/var/lib/ldap", "/run/slapd"]

EXPOSE 10389 10636

CMD ["/init"]

HEALTHCHECK CMD ["ldapsearch", "-H", "ldap://127.0.0.1:10389", "-D", "${LDAP_BINDDN}", "-w", "${LDAP_SECRET}", "-b", "${LDAP_BINDDN}"]
