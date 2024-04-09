
#!/bin/bash
# Filename: deploy-code.sh
# Description: Deploy Lambda function code to S3

cd ../laravel-app
composer install --no-dev 
php artisan config:clear
zip -q -r laravel-app.zip . -x ".env"

aws s3 cp laravel-app.zip  s3://local-dev-workspace/v0.0.6/laravel-app.zip 

rm laravel-app.zip