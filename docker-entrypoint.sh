#!/bin/bash
set -e

echo "🚀 Starting Symfony production..."

export APP_ENV=prod
export APP_DEBUG=0

echo "🔥 Clearing cache..."
php bin/console cache:clear --no-warmup || true
php bin/console cache:warmup || true


echo "📨 Starting Messenger worker..."
php bin/console messenger:consume async --time-limit=3600 &


echo "🌐 Starting Apache..."
exec apache2-foreground