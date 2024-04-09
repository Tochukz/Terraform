<?php 
require __DIR__ . '/vendor/autoload.php';

use Bref\Context\Context;

return function ($event, Context $context) {
    echo json_encode(["info" => "This is going to cloudwatch"]);
    return ['message' => sprintf("Hello, %s!", $event['name'] ?? "unknown")];
};
