<?php

use App\Kernel;

require_once dirname(__DIR__).'/vendor/autoload_runtime.php';

return function (array $context) {
    // Ne pas charger .env - utiliser les variables d'environnement Render
    // Les valeurs viennent des variables définies dans le dashboard Render
    $_SERVER['APP_ENV'] = $_ENV['APP_ENV'] = 'prod';
    $_SERVER['APP_DEBUG'] = $_ENV['APP_DEBUG'] = '0';
    
    return new Kernel($_ENV['APP_ENV'], (bool) $_ENV['APP_DEBUG']);
};
