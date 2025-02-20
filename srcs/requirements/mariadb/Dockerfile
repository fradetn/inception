FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh \
	&& mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld

EXPOSE 3306

ENTRYPOINT [ "entrypoint.sh" ]