FROM php:8.2-apache

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libzip-dev \
    && docker-php-ext-install intl zip pdo pdo_mysql opcache

# Activer les modules Apache
RUN a2enmod rewrite

# Configurer Apache pour écouter sur le port 10000 (port Render)
RUN echo 'Listen 10000' > /etc/apache2/ports.conf
RUN echo '<VirtualHost *:10000>\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html/public\n\
    \n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
        Options -Indexes +FollowSymLinks\n\
        \n\
        <IfModule mod_rewrite.c>\n\
            RewriteEngine On\n\
            RewriteCond %{REQUEST_FILENAME} !-f\n\
            RewriteRule ^(.*)$ index.php [QSA,L]\n\
        </IfModule>\n\
    </Directory>\n\
    \n\
    ErrorLog /dev/stderr\n\
    CustomLog /dev/stdout combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Désactiver le site par défaut sur le port 80
RUN a2dissite 000-default
RUN a2ensite 000-default

WORKDIR /var/www/html

# Copier les fichiers du projet
COPY . .

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Configurer Git
RUN git config --global --add safe.directory /var/www/html

# Installer les dépendances
RUN composer install --no-dev --optimize-autoloader \
    --classmap-authoritative \
    --no-scripts

# Nettoyer le cache
RUN php bin/console cache:clear --env=prod --no-debug

# Définir les permissions
RUN chown -R www-data:www-data var public

# Variables d'environnement pour production
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Exposer le port 10000 (port Render)
EXPOSE 10000

# Démarrer Apache sur le port 10000
CMD ["apache2-foreground"]