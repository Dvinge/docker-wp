FROM php:7.1-apache
RUN apt-get update \
    && apt-get install curl wget git openssl -y

RUN apt-get update \
        && apt-get install -y libpng-dev libpng-dev zlib1g-dev libicu-dev g++ \
        && docker-php-ext-configure intl \
        && docker-php-ext-install -j$(nproc) pdo pdo_mysql gd zip intl bcmath session mbstring json iconv gettext mysqli


RUN rm -rf /var/www/html/*; rm -rf /etc/apache2/sites-enabled/*; \
    mkdir -p /etc/apache2/external

RUN a2enmod rewrite

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

RUN sed -i 's/^ServerSignature/#ServerSignature/g' /etc/apache2/conf-enabled/security.conf; \
    sed -i 's/^ServerTokens/#ServerTokens/g' /etc/apache2/conf-enabled/security.conf; \
    echo "ServerSignature Off" >> /etc/apache2/conf-enabled/security.conf; \
    echo "ServerTokens Prod" >> /etc/apache2/conf-enabled/security.conf; \
    a2enmod ssl; \
    a2enmod headers; \
    echo "SSLProtocol ALL -SSLv2 -SSLv3" >> /etc/apache2/apache2.conf

ADD php/000-default.conf /etc/apache2/sites-enabled/000-default.conf
ADD php/001-default-ssl.conf /etc/apache2/sites-enabled/001-default-ssl.conf

EXPOSE 80
EXPOSE 443

ADD php/entrypoint.sh /opt/entrypoint.sh
RUN chmod a+x /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]