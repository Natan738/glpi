FROM debian:11.4
ENV DEBIAN_FRONTEND noninteractive

# Adiciona o repositório do PHP 8.3
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       gnupg \
       wget \
       lsb-release \
    && wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add - \
    && echo "deb https://packages.sury.org/php $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

# Atualiza e instala pacotes necessários, incluindo PHP 8.3
RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends \
       apache2 \
       php8.3 \
       php8.3-mysql \
       php8.3-ldap \
       php8.3-xmlrpc \
       php8.3-imap \
       curl \
       php8.3-curl \
       php8.3-gd \
       php8.3-mbstring \
       php8.3-xml \
       php8.3-apcu-bc \
       php8.3-cas \
       php8.3-intl \
       php8.3-zip \
       php8.3-bz2 \
       cron \
       ca-certificates \
       jq \
       libldap-2.4-2 \
       libldap-common \
       libsasl2-2 \
       libsasl2-modules \
       libsasl2-modules-db \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log \
    && sed -i "s/#AddDefaultCharset/AddDefaultCharset/g" /etc/apache2/conf-enabled/charset.conf \
    && echo "ServerSignature Off" >> /etc/apache2/apache2.conf \
    && rm -f /var/www/html/index.html

# Copia scripts e arquivos de configuração do GLPI
COPY glpi.sh change_upload_max_filesize.php default_upload_max_filesize.php /opt/
COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

# Define permissões para o script glpi.sh
RUN chmod +x /opt/glpi.sh

# Configuração das variáveis de ambiente do Apache
ENV APACHE_LOCK_DIR="/var/lock"
ENV APACHE_PID_FILE="/var/run/apache2.pid"
ENV APACHE_RUN_DIR="/var/run/apache2"
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# Define o diretório de trabalho
WORKDIR /root

# Expõe a porta 80 para acesso web
EXPOSE 80

# Define o entrypoint para iniciar o serviço GLPI
ENTRYPOINT ["/opt/glpi.sh"]
VOLUME ["/var/www/html"]
