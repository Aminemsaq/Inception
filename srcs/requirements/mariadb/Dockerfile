FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/my.cnf
COPY tools/db-setup.sh /db-setup.sh
RUN chmod +x /db-setup.sh

EXPOSE 3306
CMD ["/db-setup.sh"]