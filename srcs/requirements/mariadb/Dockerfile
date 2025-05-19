FROM	debian:bullseye

RUN	apt update -y && apt upgrade -y && apt-get install -y mariadb-server mariadb-client

#config mariaDB
COPY	conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

#script init DB
COPY	tools/mysql.sh /
RUN	chmod +x mysql.sh

EXPOSE	3306

STOPSIGNAL	SIGQUIT

ENTRYPOINT ["/mysql.sh"]
