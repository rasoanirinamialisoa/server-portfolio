#!/bin/bash
set -e

echo "🚀 Démarrage Symfony..."

php bin/console cache:clear --env=prod || true

apache2-foreground