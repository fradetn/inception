#!/bin/sh
set -e # Arrêter le script en cas d'erreur

# Vérification de la présence de WP-CLI
if ! command -v wp ; then
    echo "WP-CLI (wp) is not installed or not in PATH"
    exit 1
fi

# Attendre que le service MariaDB soit prêt
echo "Waiting for MariaDB to be ready..."
sleep 10

# Définir le répertoire de travail
cd /var/www/html

# Afficher le contenu du répertoire pour le débogage
#ls -la /var/www/html
#ls -la usr/local/bin

echo "DB_NAME=${DB_NAME}"
echo "DB_USER=${DB_USER}"
echo "DB_USER_PASSWORD=${DB_USER_PASSWORD}"
echo "WORDPRESS_ADMIN_USER=${WP_ADMIN_USER}"
echo "WORDPRESS_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD}"
echo "WORDPRESS_URL=${WP_URL}"
echo "WORDPRESS_TITLE=${WP_TITLE}"
echo "WORDPRESS_ADMIN_EMAIL=${WP_ADMIN_EMAIL}"
echo "WORDPRESS_USER=${WP_USER}"
echo "WORDPRESS_EMAIL=${WP_EMAIL}"
echo "WORDPRESS_PASSWORD=${WP_PASSWORD}"

# Vérifier si le fichier wp-config.php existe déjà
if [ ! -f wp-config.php ]; then
  echo "Downloading WordPress..."
  wp core download --allow-root --path='/var/www/html'

  echo "Creating WordPress configuration..."
  wp config create --allow-root \
    --dbname=$DB_NAME \
    --dbuser=$DB_USER \
    --dbpass=$DB_USER_PASSWORD \
    --dbhost=mariadb:3306 \
    --path='/var/www/html'
fi

# Vérifier si WordPress est déjà installé
if wp core is-installed --allow-root --path='/var/www/html'; then
  echo "WordPress is already installed."
else
  echo "Installing WordPress..."
  wp core install --allow-root \
    --url=$WP_URL \
    --title=$WP_TITLE \
    --admin_user=$WP_ADMIN_USER \
    --admin_password=$WP_ADMIN_PASSWORD \
    --admin_email=$WP_ADMIN_EMAIL \
    --path='/var/www/html'
fi

# Créer un utilisateur supplémentaire avec le rôle d'éditeur
if ! wp user get $WP_USER --field=user_email --allow-root --path='/var/www/html' >/dev/null 2>&1; then
  echo "Creating additional user..."
  wp user create $WP_USER $WP_EMAIL --role=editor --user_pass=$WP_PASSWORD --allow-root --path='/var/www/html'
else
  echo "User $WP_USER already exists, skipping creation."
fi

mkdir -p /run/php
chown -R www-data:www-data /run/php

# Démarrer PHP-FPM
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F