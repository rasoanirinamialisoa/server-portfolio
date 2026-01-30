#!/bin/bash

set -e

# Vérifier si PORT est défini
if [ -z "$PORT" ]; then
    echo "Warning: PORT not set, defaulting to 10000"
    export PORT=10000
fi

echo "Starting Symfony on port: $PORT"

# S'assurer que le cache est propre
if [ -d "/var/www/html/var/cache/prod" ]; then
    rm -rf /var/www/html/var/cache/prod/*
fi

# Créer le répertoire de cache si nécessaire
mkdir -p /var/www/html/var/cache/prod
mkdir -p /var/www/html/var/log

# Réchauffer le cache Symfony
php /var/www/html/bin/console cache:warmup --env=prod --no-debug 2>/dev/null || true

# Permissions
chown -R www-data:www-data /var/www/html/var
chown -R www-data:www-data /var/www/html/public

# Remplacer le port dans la configuration Apache
sed -i "s/Listen 80/Listen $PORT/g" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:$PORT>/g" /etc/apache2/sites-available/000-default.conf

echo "Configuration complete. Starting Apache..."

exec apache2-foreground