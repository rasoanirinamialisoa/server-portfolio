#!/bin/bash
set -e

echo "Starting Symfony..."

# permissions correctes AVANT cache
chown -R www-data:www-data var public || true
chmod -R 775 var public || true

# ne pas supprimer cache manuellement
echo "Warming cache..."
php bin/console cache:warmup --env=prod --no-debug || true

exec apache2-foreground