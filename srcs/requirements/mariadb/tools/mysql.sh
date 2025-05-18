#!/bin/bash

chown -R mysql:mysql /var/lib/mysql

export MYSQL_PASSWORD=$(cat /run/secrets/db_password)
export MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
export ADMIN_PASSWORD=$(grep 'ADMIN_PASSWORD' /run/secrets/credentials | cut -d '=' -f2)
export WP_PASSWORD=$(grep 'WP_PASSWORD' /run/secrets/credentials | cut -d '=' -f2)


mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

# Fonction pour afficher un message d'erreur et quitter le script
function error_exit {
    echo "$1" >&2
    exit 1
}

# Démarrer MariaDB normalement
echo "Starting MariaDB..."
/usr/bin/mysqld_safe --datadir=/var/lib/mysql &

# Attendre que MariaDB soit prêt
until mysql -u root -e "status" > /dev/null 2>&1; do
    echo "MariaDB not ready yet. Retrying in 5 seconds..."
    sleep 5
done
echo "MariaDB is ready."

if [ -n "${MYSQL_DATABASE}" ]; then
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
	if [ -n "${MYSQL_USER}" ] && [ -n "${MYSQL_PASSWORD}" ]; then
		mysql -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"
		mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
		mysql -u root -e "FLUSH PRIVILEGES;"
	fi
fi

if ! mysqladmin shutdown; then
	error_exit "failed to shut own Mariadb."
fi

# Démarrer MariaDB en mode foreground pour que le conteneur reste actif
echo "Starting MariaDB normally..."
exec mysqld_safe --datadir=/var/lib/mysql
