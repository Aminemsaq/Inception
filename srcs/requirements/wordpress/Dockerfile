FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm php-mysql php-mbstring \
    default-mysql-client wget

RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000
CMD ["/usr/local/bin/wp-setup.sh"]