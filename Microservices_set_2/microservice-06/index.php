<?php

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;

require __DIR__ . '/vendor/autoload.php';

$app = AppFactory::create();

$serviceName = getenv('SERVICE_NAME') ?: 'service-php-06';

$app->get('/', function (Request $request, Response $response, $args) {
    $response->getBody()->write("Hello from Microservice 06 (PHP Slim)");
    return $response;
});

$app->get('/ping', function (Request $request, Response $response, $args) use ($serviceName) {
    $payload = json_encode(['status' => 'ok', 'service' => $serviceName]);
    $response->getBody()->write($payload);
    return $response->withHeader('Content-Type', 'application/json');
});

$app->get('/spike', function (Request $request, Response $response, $args) use ($serviceName) {
    $queryParams = $request->getQueryParams();
    $duration = isset($queryParams['duration']) ? (int)$queryParams['duration'] : 10;
    $endTime = microtime(true) + $duration;

    while (microtime(true) < $endTime) {
        sqrt(64 * 64 * 64 * 64);
    }

    $payload = json_encode([
        'message' => "CPU spiked for {$duration} seconds",
        'service' => $serviceName
    ]);
    $response->getBody()->write($payload);
    return $response->withHeader('Content-Type', 'application/json');
});

$app->run();