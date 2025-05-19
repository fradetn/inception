#!/bin/bash

sleep 10;
# Chemin vers le repertoire WordPress
WP_PATH=/var/www/wordpress/

cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php

export MYSQL_PASSWORD=$(cat /run/secrets/db_password)
export MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
export ADMIN_PASSWORD=$(grep 'ADMIN_PASSWORD' /run/secrets/credentials | cut -d '=' -f2)
export WP_PASSWORD=$(grep 'WP_PASSWORD' /run/secrets/credentials | cut -d '=' -f2)


if [ -n "$MYSQL_DATABASE" ]; then
	sed -i "s|define( 'DB_NAME', 'database_name_here' );|define( 'DB_NAME', '$MYSQL_DATABASE' );|" /var/www/wordpress/wp-config.php
	if [ -n "$MYSQL_USER" ]; then
		sed -i "s|define( 'DB_USER', 'username_here' );|define( 'DB_USER', '$MYSQL_USER' );|" /var/www/wordpress/wp-config.php
		if [ -n "$MYSQL_PASSWORD" ]; then
    		sed -i "s|define( 'DB_PASSWORD', 'password_here' );|define( 'DB_PASSWORD', '$MYSQL_PASSWORD' );|" /var/www/wordpress/wp-config.php
		sed -i "s|define( 'DB_HOST', 'localhost' );|define( 'DB_HOST', 'mariadb' );|" /var/www/wordpress/wp-config.php
		fi
	fi
fi
	# Vérifie si WordPress est déjà installé
	if ! wp core is-installed --path=$WP_PATH --allow-root; then
		echo "WordPress non installé. Installation en cours..."
		wp core install --path=$WP_PATH \
			--url="${DOMAIN_NAME}" \
			--title="${TITLE_NAME}" \
			--admin_user="${ADMIN_USER}" \
			--admin_password="${ADMIN_PASSWORD}" \
			--admin_email="admin@mail.com" \
			--allow-root
	else
		echo "WordPress est déjà installé."
	fi

	# Vérifie si l'utilisateur secondaire existe déjà
	if ! wp user get "${WP_USER}" --path=$WP_PATH --allow-root > /dev/null 2>&1; then
		echo "Création de l'utilisateur ${WP_USER}..."
		wp user create "${WP_USER}" "user@mail.com" \
			--user_pass="${WP_PASSWORD}" \
			--role="${WP_USER_ROLE:-author}" \
			--path=$WP_PATH \
			--allow-root
	else
		echo "L'utilisateur ${WP_USER} existe déjà."
	fi

#Lancement de PHP-FPM
/usr/sbin/php-fpm7.4 -F
