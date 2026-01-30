# -----------------------------
# Base image
# -----------------------------
FROM php:8.2-apache

# -----------------------------
# Installer dépendances système et PHP extensions
# -----------------------------
RUN apt-get update && apt-get install -y \
        git unzip libicu-dev libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
        nano less \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) intl zip pdo pdo_mysql opcache gd \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Définir le working directory
# -----------------------------
WORKDIR /var/www/html

# -----------------------------
# Copier le projet
# -----------------------------
COPY . .

# -----------------------------
# Installer Composer
# -----------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# -----------------------------
# Config Git safe
# -----------------------------
RUN git config --global --add safe.directory /var/www/html

# -----------------------------
# Variables d'environnement
# -----------------------------
ENV APP_ENV=prod
ENV APP_DEBUG=0

# -----------------------------
# Installer les dépendances Symfony en prod
# -----------------------------
RUN composer install --no-dev --optimize-autoloader --no-scripts

# -----------------------------
# Nettoyer les fichiers dev/test
# -----------------------------
RUN rm -f config/packages/dev/*.yaml config/packages/test/*.yaml || true

# -----------------------------
# Permissions
# -----------------------------
RUN mkdir -p var/cache var/log \
    && chown -R www-data:www-data var public \
    && chmod -R 775 var public

# -----------------------------
# Précompiler le cache Symfony pour prod
# -----------------------------
USER www-data
RUN php bin/console cache:clear --no-warmup
RUN php bin/console cache:warmup

# -----------------------------
# Script d'entrée
# -----------------------------
USER root
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
