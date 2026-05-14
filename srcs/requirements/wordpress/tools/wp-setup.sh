#!/bin/bash

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)

echo "Waiting for MariaDB..."
while ! mysqladmin ping -h mariadb -u $MYSQL_USER -p$DB_PASSWORD --silent 2>/dev/null; do
    sleep 2
done
echo "MariaDB is ready!"

wp core download --allow-root --path=/var/www/html

wp config create --allow-root \
        --path=/var/www/html \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$DB_PASSWORD \
        --dbhost=mariadb:3306

wp core install --allow-root \
        --path=/var/www/html \
        --url=https://$DOMAIN_NAME \
        --title="Amsaq Inception" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --skip-email

wp user create $MYSQL_USER2 $WP_USER_EMAIL \
        --role=editor \
        --user_pass=$DB_PASSWORD \
        --allow-root \
        --path=/var/www/html

chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F