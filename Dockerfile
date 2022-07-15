FROM debian:11.4
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt dist-upgrade -y && apt autoremove -y \
	&& apt install --yes --no-install-recommends apache2 php php-mysql php-ldap \
	php-xmlrpc php-imap curl php-curl php-gd php-mbstring php-xml php-apcu-bc \
	php-cas php-intl php-zip php-bz2 cron wget ca-certificates jq libldap-2.4-2 \
	libldap-common libsasl2-2 libsasl2-modules libsasl2-modules-db && \
	apt-get clean all && rm -rf /var/lib/apt/lists/* && \
	ln -sf /dev/stdout /var/log/apache2/access.log && \
	ln -sf /dev/stderr /var/log/apache2/error.log && \
	sed -i "s/#AddDefaultCharset/AddDefaultCharset/g" /etc/apache2/conf-enabled/charset.conf && \
	echo "ServerSignature Off" >> /etc/apache2/apache2.conf \
	&& sed -i "s/2M/500M/" /etc/php/7.4/apache2/php.ini \
	&& sed -i "s/2M/500M/" /etc/php/7.4/cli/php.ini \
	&& sed -i "s/2M/500M/" /usr/lib/php/7.4/php.ini-development \
	&& sed -i "s/2M/500M/" /usr/lib/php/7.4/php.ini-production \
	&& sed -i "s/2M/500M/" /usr/lib/php/7.4/php.ini-production.cli \
	&& sed -i "s/2M/500M/" /usr/lib/php/7.4/php.ini-production.cli \
	&& rm -f /var/www/html/index.html \
	&& sed -i "s/post_max_size = 8M/post_max_size = 100M/" /etc/php/7.4/apache2/php.ini \
	&& sed -i "s/post_max_size = 8M/post_max_size = 100M/" /etc/php/7.4/cli/php.ini \
	&& sed -i "s/post_max_size = 8M/post_max_size = 100M/" /usr/lib/php/7.4/php.ini-development \
	&& sed -i "s/post_max_size = 8M/post_max_size = 100M/" /usr/lib/php/7.4/php.ini-production \
	&& sed -i "s/post_max_size = 8M/post_max_size = 100M/" /usr/lib/php/7.4/php.ini-production.cli \
	&& sed -i "s/post_max_size = 8M/post_max_size = 100M/" /usr/lib/php/7.4/php.ini-production.cli

COPY glpi.sh /opt/
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf
RUN chmod +x /opt/glpi.sh

ENV APACHE_LOCK_DIR="/var/lock"
ENV APACHE_PID_FILE="/var/run/apache2.pid"
ENV APACHE_RUN_DIR="/var/run/apache2"
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

WORKDIR /root

ENTRYPOINT ["/opt/glpi.sh"]

EXPOSE 80
VOLUME ["/var/www/html"]