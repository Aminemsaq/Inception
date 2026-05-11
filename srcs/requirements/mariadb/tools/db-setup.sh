#!/bin/bash

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/wordpress" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    mysqld_safe --skip-networking &
    sleep 5

    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
    mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS wordpress;"
    mysql -u root -p${DB_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS 'amsaq_user'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
    mysql -u root -p${DB_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'amsaq_user'@'%';"
    mysql -u root -p${DB_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

    mysqladmin -u root -p${DB_ROOT_PASSWORD} shutdown
    sleep 3
fi

exec "$@"
