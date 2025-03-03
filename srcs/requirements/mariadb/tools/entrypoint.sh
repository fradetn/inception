#!/bin/bash

# Démarrage temporaire du serveur
mysqld_safe &

# Attente du démarrage de MariaDB
echo "Attente du démarrage de MariaDB..."
while ! mysqladmin ping -h localhost -u root --silent; do
    sleep 1
done

echo "MariaDB démarré, configuration des accès..."

# Configuration des accès
mysql -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;"

mysql -u root -p"${DB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';"

mysql -u root -p"${DB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO ${DB_USER}@'%';"

mysql -u root -p"${DB_ROOT_PASSWORD}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"

mysql -u root -p"${DB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# Arrêt propre du serveur temporaire
mysqladmin -u root -p${DB_ROOT_PASSWORD} shutdown

# Exécution du serveur en avant-plan
exec mysqld_safe --datadir=/var/lib/mysql