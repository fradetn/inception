FROM	debian:bullseye

RUN	apt update -y && apt upgrade -y && apt install -y wget php php-fpm php-mysql

#install wordpress
RUN	wget https://fr.wordpress.org/wordpress-6.6-fr_FR.tar.gz -P /var/www
RUN	cd /var/www && tar -xzf wordpress-6.6-fr_FR.tar.gz && rm wordpress-6.6-fr_FR.tar.gz

#Config php
COPY	/conf/www.conf /etc/php/7.4/fpm/pool.d/
RUN	chmod 644 /etc/php/7.4/fpm/pool.d/www.conf

#installi WP-CLI
RUN	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY	/tools/init_wordpress.sh /
RUN	chmod +x init_wordpress.sh \
    && chown -R www-data:www-data /var/www/wordpress \
    && chmod -R 755 /var/www/wordpress \
    && mkdir -p /run/php \
    && chown www-data:www-data /run/php \
    && chmod 755 /run/php

EXPOSE	9000

STOPSIGNAL	SIGQUIT

ENTRYPOINT	["/init_wordpress.sh"]
