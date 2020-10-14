FROM php:7.3-alpine
ARG KODEXPLORER_URL="http://static.kodcloud.com/update/download/kodexplorer4.40.zip"

RUN set -x \
  && mkdir -p /usr/src/kodexplorer \
  && apk --update --no-cache add wget bash
WORKDIR /usr/src/kodexplorer
RUN wget "$KODEXPLORER_URL" \
  && unzip kodexplorer4.40.zip && rm kodexplorer4.40.zip

RUN set -x \
  && apk add --no-cache --update \
     freetype libpng libjpeg-turbo \
     freetype-dev libpng-dev libjpeg-turbo-dev \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j "$(getconf _NPROCESSORS_ONLN)" gd \
  && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

WORKDIR /var/www/html

COPY entrypoint.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD [ "php", "-S", "0000:80", "-t", "/var/www/html" ]
