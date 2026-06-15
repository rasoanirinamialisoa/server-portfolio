<?php
require __DIR__ . '/../vendor/autoload.php';

use Symfony\Component\HttpFoundation\JsonResponse;

try {
    $response = new JsonResponse([
        'status' => 'ok',
        'message' => 'Symfony fonctionne'
    ]);
    $response->send();
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
