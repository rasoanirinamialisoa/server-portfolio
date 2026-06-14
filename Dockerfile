# =========================
# 1) COMPOSER BUILD STAGE
# =========================
FROM composer:2 AS builder

WORKDIR /app

# Copy only dependency files first (cache layer optimization)
COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --no-progress \
    --optimize-autoloader

# Copy full project AFTER install (better cache)
COPY . .

# =========================
# 2) RUNTIME STAGE
# =========================
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

# Apache Symfony public/
RUN sed -i 's#/var/www/html#/var/www/html/public#g' \
    /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html

# =========================
# ENV PRODUCTION SAFE
# =========================
ENV APP_ENV=prod
ENV APP_DEBUG=0

# =========================
# COPY APP FROM BUILDER
# =========================
COPY --from=builder /app /var/www/html

# =========================
# PERMISSIONS
# =========================
RUN mkdir -p var/cache var/log \
    && chown -R www-data:www-data var

USER www-data

CMD ["apache2-foreground"]