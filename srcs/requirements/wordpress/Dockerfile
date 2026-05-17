FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm php-mysql php-mbstring \
    default-mysql-client wget

WORKDIR /usr/local/bin

RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar wordpress

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/wp-setup.sh .
RUN chmod +x wp-setup.sh

EXPOSE 9000
CMD ["wp-setup.sh"]