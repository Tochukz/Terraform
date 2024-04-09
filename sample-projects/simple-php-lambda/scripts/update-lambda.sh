#!/bin/bash
# Filename: update-lambda.sh
# Description: Update lambda function code

aws lambda update-function-code --function-name Simple_PHP --s3-key v0.0.2/sample-php.zip --s3-bucket local-dev-workspace > output.json