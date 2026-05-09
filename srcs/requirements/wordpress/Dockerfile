FROM debian:bookworm

RUN apt-get update
RUN apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    php-curl \
    php-dom \
    php-imagick \
    php-mbstring \
    php-zip \
    php-intl \
    wget \
    curl \
    default-mysql-client

RUN mkdir -p /var/www/html

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/wp-setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]
CMD ["/usr/sbin/php-fpm8.2", "-F"]
