
#!/bin/bash
# Filename: deploy-code.sh
# Description: Deploy Lambda function code to S3

cd ../sample-php
zip -r sample-php.zip . -x "vendor/*"

mkdir php
cp composer.json php/composer.json
cp composer.lock php/composer.lock
cd php
composer install
cd ../
zip -r php-vendor.zip php

aws s3 cp sample-php.zip  s3://local-dev-workspace/v0.0.4/sample-php.zip 
aws s3 cp php-vendor.zip  s3://local-dev-workspace/v0.0.4/php-vendor.zip

rm -r php
rm php-vendor.zip
rm sample-php.zip