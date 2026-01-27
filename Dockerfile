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

# Configurer Apache pour Render (port 10000)
RUN echo 'Listen 10000' > /etc/apache2/ports.conf
RUN echo '<VirtualHost *:10000>\n\
    ServerName localhost\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
        FallbackResource /index.php\n\
    </Directory>\n\
    ErrorLog /dev/stderr\n\
    CustomLog /dev/stdout combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Désactiver le site par défaut sur port 80
RUN sed -i '/Listen 80/d' /etc/apache2/ports.conf

WORKDIR /var/www/html

# Copier les fichiers
COPY . .

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Résoudre problème Git
RUN git config --global --add safe.directory /var/www/html

# ÉTAPE CRITIQUE : Installer d'abord TOUTES les dépendances pour générer le cache correctement
RUN composer install --no-interaction --prefer-dist

# Nettoyer le cache en mode dev (pour générer les fichiers correctement)
RUN APP_ENV=dev php bin/console cache:clear

# ÉTAPE CRITIQUE : Maintenant installer seulement les dépendances de production
# MAIS garder le cache généré précédemment
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Régénérer le cache en mode production
RUN APP_ENV=prod APP_DEBUG=0 php bin/console cache:clear --no-debug

# Créer les répertoires nécessaires
RUN mkdir -p var/cache/prod var/log var/sessions \
    && chmod -R 777 var \
    && chown -R www-data:www-data var public

# Variables d'environnement pour la production
ENV APP_ENV=prod
ENV APP_DEBUG=0

EXPOSE 10000

CMD ["apache2-foreground"]