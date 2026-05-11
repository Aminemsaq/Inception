#!/bin/bash

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)

echo "Waiting for MariaDB..."
while ! mysqladmin ping -h mariadb -u amsaq_user -p${DB_PASSWORD} --silent 2>/dev/null; do
    sleep 2
done
echo "MariaDB is ready!"

if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root --path=/var/www/html

    wp config create --allow-root \
        --path=/var/www/html \
        --dbname=wordpress \
        --dbuser=amsaq_user \
        --dbpass=${DB_PASSWORD} \
        --dbhost=mariadb:3306

    wp core install --allow-root \
        --path=/var/www/html \
        --url=https://amsaq.42.fr \
        --title="Amsaq Inception" \
        --admin_user=amsaq42 \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=amsaq@student.42.fr \
        --skip-email

    wp user create --allow-root \
        --path=/var/www/html \
        amsaq_editor editor@student.42.fr \
        --role=editor \
        --user_pass=${WP_ADMIN_PASSWORD}

    chown -R www-data:www-data /var/www/html
fi

exec "$@"
