#!/bin/bash

PASSWORD=$(cat /run/secrets/password)

while ! mysqladmin ping -h mariadb -u $MYSQL_USER -p$PASSWORD --silent 2>/dev/null; do
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root --path=/var/www/html

    wp config create --allow-root --path=/var/www/html \
        --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER \
        --dbpass=$PASSWORD --dbhost=mariadb

    wp core install --allow-root --path=/var/www/html \
        --url=https://$DOMAIN_NAME --title="Amsaq Inception" \
        --admin_user=$WP_ADMIN_USER --admin_password=$PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL --skip-email

    wp user create $MYSQL_USER2 $WP_USER_EMAIL \
        --user_pass=$PASSWORD --allow-root --path=/var/www/html

    chown -R www-data:www-data /var/www/html
fi

exec php-fpm8.2 -F