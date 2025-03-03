FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/

RUN chown -R mysql:mysql /var/lib/mysql \
	&& chmod -R 750 /var/lib/mysql \
	&& chmod +x /usr/local/bin/entrypoint.sh \
	&& echo "entrypoint.sh :" && \
	ls -l /usr/local/bin/entrypoint.sh

EXPOSE 3306

ENTRYPOINT [ "entrypoint.sh" ]