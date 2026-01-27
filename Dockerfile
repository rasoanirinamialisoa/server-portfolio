FROM php:8.2-apache

# Mettre à jour et installer les dépendances
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        intl \
        zip \
        pdo \
        pdo_mysql \
        opcache \
        gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Activer Apache modules
RUN a2enmod rewrite

# Configurer pour Render (port 10000)
RUN echo 'Listen 10000' > /etc/apache2/ports.conf
RUN echo '<VirtualHost *:10000>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
        FallbackResource /index.php\n\
    </Directory>\n\
    ErrorLog /dev/stderr\n\
    CustomLog /dev/stdout combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html

# Copier les fichiers
COPY . .

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Résoudre problème Git
RUN git config --global --add safe.directory /var/www/html

# Mode développement pour voir les erreurs
ENV APP_ENV=dev
ENV APP_DEBUG=1

# Installer toutes les dépendances
RUN composer install --no-interaction --prefer-dist

# Vider le cache
RUN php bin/console cache:clear

# Créer les répertoires nécessaires
RUN mkdir -p var/cache var/log var/sessions \
    && chmod -R 777 var \
    && chown -R www-data:www-data var public

EXPOSE 10000

CMD ["apache2-foreground"]