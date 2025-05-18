FROM	debian:bullseye

RUN 	apt update -y && apt upgrade -y && apt install nginx -y

#gestion et creation de certificat SSL
RUN	mkdir -p /etc/nginx/ssl
RUN	apt install openssl -y
RUN	openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=PACA/L=Nice/O=42/OU=42/CN=nfradet.42.fr/UID=login"

#config NGINX
RUN	mkdir -p /var/run/nginx
COPY	conf/nginx.conf /etc/nginx/nginx.conf
RUN	chmod 755 /var/www/html
RUN	chown -R www-data:www-data /var/www/html

EXPOSE	443

STOPSIGNAL	SIGQUIT

CMD	["nginx", "-g", "daemon off;"]
