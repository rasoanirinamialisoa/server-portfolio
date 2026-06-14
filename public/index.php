<?php
// Dans public/index.php ou config/bootstrap.php
use Symfony\Component\Dotenv\Dotenv;

// Ne charge le .env qu'en environnement local
if (!isset($_SERVER['APP_ENV']) && !isset($_ENV['APP_ENV'])) {
    if (file_exists(dirname(__DIR__).'/.env')) {
        (new Dotenv())->usePutenv()->bootEnv(dirname(__DIR__).'/.env');
    }
}