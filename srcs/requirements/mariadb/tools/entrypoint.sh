#!/bin/bash

set -e

# Initialisation de la base de données
if [ ! -d "/var/lib/mysql/mysql" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Démarrage temporaire du serveur
mysqld_safe --mowatch \
	--datadir=/var/lib/mysql \
	--user=mysql \
	--skip-networking=0 \
	--wsrep_on=OFF \
	--expire-logs-days=0 \
	--general-logs=1 \
	--max-allowed-package=64M &

# Attente du démarrage de MySQL
while ! mysqladmin ping --silent; do
	sleep 1
done

# Configuration des accès
mysql -uroot <<-EOSQL
    SET @@SESSION.SQL_LOG_BIN=0;
    CREATE DATABASE IF NOT EXISTS \${DB_NAME};
    CREATE USER IF NOT EXISTS \${DB_USER}@'%' IDENTIFIED BY '\${DB_PASS}';
    GRANT ALL PRIVILEGES ON \${DB_NAME}.* TO \${DB_USER}@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '\${DB_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

# Arrêt propre du serveur temporaire
mysqladmin -uroot -p\${DB_ROOT_PASSWORD} shutdown

# Exécution du serveur en avant-plan
exec mysqld_safe --datadir=/var/lib/mysql