FROM php:8.2-apache

# =========================
# SYSTEM DEPENDENCIES
# =========================
RUN apt-get update && apt-get install -y \
    git unzip curl \
    libicu-dev libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install intl zip pdo pdo_mysql opcache gd \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# =========================
# APACHE CONFIG (Symfony public/)
# =========================
RUN sed -i 's#/var/www/html#/var/www/html/public#g' \
    /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html

# =========================
# PRODUCTION ENV (IMPORTANT)
# =========================
ENV APP_ENV=prod
ENV APP_DEBUG=0

# =========================
# COMPOSER
# =========================
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# =========================
# COPY PROJECT
# =========================
COPY . .

# =========================
# INSTALL DEPENDENCIES (PRODUCTION OPTIMIZED)
# =========================
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-progress

# =========================
# CACHE + LOG PERMISSIONS
# =========================
RUN mkdir -p var/cache var/log \
    && chown -R www-data:www-data var public

# =========================
# ENTRYPOINT
# =========================
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER www-data

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]