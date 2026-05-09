#!/bin/bash

# Read passwords from secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Only initialize if database doesn't exist yet
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    mysqld_safe --skip-networking &
    sleep 5

    mysql -u root << SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL

    sed "s/DB_PASSWORD_PLACEHOLDER/${DB_PASSWORD}/" /usr/local/bin/wordpress.sql | mysql -u root -p${DB_ROOT_PASSWORD}

    mysqladmin -u root -p${DB_ROOT_PASSWORD} shutdown
    sleep 3
fi

exec "$@"
