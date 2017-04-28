# Expose the debian repository to port 80 so it can be added
# in sources.list

FROM ubuntu:16.04
MAINTAINER Emmanuel Lepage-Vallee (elv1313@gmail.com)

RUN apt update
RUN apt upgrade -y

RUN apt install -yy nginx

ADD sites-enabled /etc/nginx/sites-enabled/default

WORKDIR /var/www/html

EXPOSE 80
EXPOSE 443

CMD nginx -g 'daemon off;'
