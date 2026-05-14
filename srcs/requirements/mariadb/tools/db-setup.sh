#!/bin/bash

PASSWORD=$(cat /run/secrets/password)

mysqld_safe &
until mysqladmin ping --silent; do sleep 2; done

mysql << EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$PASSWORD';
FLUSH PRIVILEGES;
EOF

mysqladmin -u root -p$PASSWORD shutdown
exec mysqld_safe