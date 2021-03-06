FROM debian:buster

# UPDATE
RUN apt-get update
RUN apt-get upgrade -y

# INSTALL NGINX & MYSQL & PHP & WGET
RUN apt-get -y install nginx
RUN apt-get -y install mariadb-server
RUN apt-get -y install php7.3 php-mysql php-fpm php-cli php-mbstring
RUN apt-get -y install wget

# COPY CONTENT
COPY ./srcs/start.sh /var/
COPY ./srcs/mysql_setup.sql /var/
COPY ./srcs/wordpress.tar.gz /var/www/html/
COPY ./srcs/nginx.conf /etc/nginx/sites-available/localhost
COPY ./srcs/index.html /var/www/html
COPY ./srcs/img /var/www/html/img

# SETUP LINK
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost

# INSTALL PHPMYADMIN 5.0.1
WORKDIR /var/www/html/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.1/phpMyAdmin-5.0.1-english.tar.gz
RUN tar xf phpMyAdmin-5.0.1-english.tar.gz && rm -rf phpMyAdmin-5.0.1-english.tar.gz
RUN mv phpMyAdmin-5.0.1-english phpmyadmin
COPY ./srcs/config.inc.php phpmyadmin

# INSTALL WORDPRESS
RUN tar xf ./wordpress.tar.gz && rm -rf wordpress.tar.gz
RUN chmod 755 -R wordpress

# SETUP SERVER & SSL
RUN service mysql start && mysql -u root mysql < /var/mysql_setup.sql
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=ES/ST=Madrid/L=Madrid/O=42Madrid/CN=dbalboa-' -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt
RUN chown -R www-data:www-data *
RUN chmod 755 -R *

# START SERVER
CMD bash /var/start.sh

# PUBLISHED PORTS
EXPOSE 80 443
