
#!/bin/bash
# Filename: deploy-code.sh
# Description: Deploy Lambda function code to S3

cd ../sample-php
composer install
zip -r sample-php.zip . 

aws s3 cp sample-php.zip  s3://local-dev-workspace/v0.0.5/sample-php.zip 

rm sample-php.zip