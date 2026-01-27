FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev \
    && docker-php-ext-install intl zip pdo pdo_mysql opcache

RUN a2enmod rewrite

WORKDIR /var/www/html

COPY . .

RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN git config --global --add safe.directory /var/www/html

RUN composer install --no-dev --optimize-autoloader \
    --classmap-authoritative \
    --no-scripts

RUN php bin/console cache:clear --env=prod --no-debug

RUN chown -R www-data:www-data var

EXPOSE 80

CMD ["apache2-foreground"]