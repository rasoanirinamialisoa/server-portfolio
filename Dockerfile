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

# Désactiver l'écoute sur le port 80
RUN sed -i '/Listen 80/d' /etc/apache2/ports.conf

WORKDIR /var/www/html

# Copier les fichiers
COPY . .

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Résoudre problème Git
RUN git config --global --add safe.directory /var/www/html

# Forcer l'environnement de production
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Modifier config/bundles.php pour désactiver DebugBundle et WebProfilerBundle complètement
RUN sed -i "s/Symfony\\\\Bundle\\\\DebugBundle\\\\DebugBundle::class => \['dev' => true, 'test' => true\]/Symfony\\\\Bundle\\\\DebugBundle\\\\DebugBundle::class => ['dev' => false, 'test' => false]/" config/bundles.php
RUN sed -i "s/Symfony\\\\Bundle\\\\WebProfilerBundle\\\\WebProfilerBundle::class => \['dev' => true, 'test' => true\]/Symfony\\\\Bundle\\\\WebProfilerBundle\\\\WebProfilerBundle::class => ['dev' => false, 'test' => false]/" config/bundles.php
RUN sed -i "s/Symfony\\\\Bundle\\\\MakerBundle\\\\MakerBundle::class => \['dev' => true\]/Symfony\\\\Bundle\\\\MakerBundle\\\\MakerBundle::class => ['dev' => false]/" config/bundles.php

# Installer sans les dépendances de dev
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Nettoyer le cache
RUN php bin/console cache:clear --no-debug

# Vérifier que les bundles de dev sont bien désactivés
RUN echo "=== Vérification des bundles ===" && \
    cat config/bundles.php && \
    echo "=== Fin de vérification ==="

# Créer les répertoires nécessaires avec les bonnes permissions
RUN mkdir -p var/cache/prod var/log var/sessions \
    && chmod -R 777 var \
    && chown -R www-data:www-data var public

EXPOSE 10000

CMD ["apache2-foreground"]