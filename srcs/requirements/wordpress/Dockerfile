FROM debian:bullseye-slim

# Mise à jour et installation des dépendences
RUN apt-get update && apt-get install -y \
    wget nano curl \
    php-fpm \
    php-xml \
    php-dom \
    php-zip \
    php-curl \
    php-exif \
    php-json \
    sendmail \
    php-mysql \
    php-fileinfo \
    php-mbstring \
    mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

# Installation de WP-CLI (outil en ligne de commande WordPress)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Vérification de l'installation
RUN wp --version --allow-root

# Création du dossier où sera stocké WordPress
RUN mkdir -p /var/www/html

# Installation, extraction de wordpress
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /var/www/html \
    && rm /tmp/wordpress.tar.gz \
    && chown -R www-data:www-data /var/www/html/wordpress

# Copie du fichier de conf php
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

CMD ["/usr/local/bin/entrypoint.sh"]