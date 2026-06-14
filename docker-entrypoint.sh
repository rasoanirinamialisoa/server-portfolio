#!/bin/bash
set -e

echo "🚀 Starting Symfony production..."

export APP_ENV=prod
export APP_DEBUG=0

# Warm up cache safely (no crash if env missing)
php bin/console cache:clear --no-warmup || true
php bin/console cache:warmup || true

exec apache2-foreground