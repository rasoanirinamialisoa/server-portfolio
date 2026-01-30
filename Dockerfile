FROM php:8.2-apache

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) intl zip pdo pdo_mysql opcache gd \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Copier tous les fichiers
COPY . .

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Résoudre problème Git
RUN git config --global --add safe.directory /var/www/html

# Variables d'environnement
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Installer les dépendances en production
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Nettoyer les bundles de développement
RUN rm -f config/packages/dev/*.yaml config/packages/test/*.yaml || true

# Permissions
RUN mkdir -p var/cache/prod var/log \
    && chown -R www-data:www-data var public

# Script d'entrée
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]