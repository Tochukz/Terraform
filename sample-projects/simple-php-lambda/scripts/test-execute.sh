#!/bin/bash
# Filename: test-execute.sh
# Description: Test the deployed lambda function with sample event payload.

aws lambda invoke --function-name Simple_PHP --payload '{ "name": "Tochukz" }' --cli-binary-format raw-in-base64-out output.json
cat output.json