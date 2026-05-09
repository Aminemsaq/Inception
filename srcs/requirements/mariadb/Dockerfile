FROM debian:bookworm

RUN apt-get update
RUN apt-get install -y mariadb-server mariadb-client

RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 777 /var/run/mysqld

EXPOSE 3306

COPY ./conf/my.cnf /etc/mysql/mariadb.conf.d/my.cnf
COPY ./tools/db-setup.sh /usr/local/bin/
COPY ./conf/wordpress.sql /usr/local/bin/

RUN chmod +x /usr/local/bin/db-setup.sh
RUN chmod +x /usr/local/bin/wordpress.sql

ENTRYPOINT ["/usr/local/bin/db-setup.sh"]
CMD ["mysqld", "--bind-address=0.0.0.0"]
