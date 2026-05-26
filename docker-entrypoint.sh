#!/bin/bash
set -e

echo "🚀 Starting Symfony..."

php bin/console cache:clear --env=prod || true
php bin/console cache:warmup --env=prod || true

exec apache2-foreground