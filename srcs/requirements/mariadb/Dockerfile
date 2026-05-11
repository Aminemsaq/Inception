FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server mariadb-client

RUN mkdir -p /var/run/mysqld /run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld /run/mysqld \
    && chmod 777 /var/run/mysqld /run/mysqld

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/my.cnf
COPY tools/db-setup.sh /usr/local/bin/db-setup.sh

RUN chmod +x /usr/local/bin/db-setup.sh

EXPOSE 3306

ENTRYPOINT ["db-setup.sh"]
CMD ["mysqld", "--bind-address=0.0.0.0"]
