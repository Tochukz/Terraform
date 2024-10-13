#!/bin/bash
# Filename: deploy-pharm-server.sh
# Description: Deploy Lambda function code to S3
# To upload and deploy only lambda function but not the layer, ./deploy-pharm-server.sh 0.0.1 prod --nolayer 

version=$1
env=$2
nolayer=$3

if test -z "$version"
then
  echo "Please supply a version number as the first argument for the script e.g ./deploy-pharm-server.sh 0.0.1 prod --nolayer"
  exit
fi 

case $env in 
  dev)    
    prefix=Dev
    enviromment=development
    ;;
  staging)
    prefix=Staging
    enviromment=staging
    ;;
  prod)
    prefix=Prod
    enviromment=production
    ;;
  *)
    echo -n "Unsupported environment "
    exit
    ;;
esac

cd ../../pharm/pharm-server 
zip -q -r pharm.zip . -x ".*" "node_modules/*" "migrations/*" "resources/*" "seeders/*" "tmp/*" "sql/*" "output/*"

if [ -z "$nolayer" ] 
then
  mkdir nodejs
  cp package.json nodejs/
  cd nodejs
  npm install --omit=dev
  cd ../
  zip -q -r pharm_nodejs.zip nodejs
else
  echo "No packaging of node_modules"
fi

echo "Copying pharm.zip to S3 bucket with key: v$version/pharm.zip" 
aws s3 cp pharm.zip s3://firdmedical-$env-deployment-artifacts/v$version/pharm.zip 

echo "Updating lambda function..."  
aws lambda update-function-code --function-name FirdMedicalsPharm_${prefix} --s3-key v$version/pharm.zip --s3-bucket firdmedical-${env}-deployment-artifacts > pharm-lambda-func.json
rm pharm.zip

if [ -z "$nolayer" ]; then
  echo "Copying pharm_nodejs.zip to S3 bucket with key: v$version/pharm_nodejs.zip" 
  aws s3 cp pharm_nodejs.zip s3://firdmedical-$env-deployment-artifacts/v$version/pharm_nodejs.zip 

  echo "Publishing lambda layer version..."
  LayerVersionArnWithQuotes=$(aws lambda publish-layer-version --layer-name FirdMedicalsPharm_${prefix} --content S3Bucket=firdmedical-${env}-deployment-artifacts,S3Key=v$version/pharm_nodejs.zip --query LayerVersionArn)
  LayerVersionArn=$(sed -e 's/^"//' -e 's/"$//' <<<"$LayerVersionArnWithQuotes") 
  echo "LayerVersionArn=${LayerVersionArn}"

  rm -r nodejs
  rm pharm_nodejs.zip

  echo "Updating lambda configuration..."
  aws lambda update-function-configuration --function-name FirdMedicalsPharm_${prefix}  --layers $LayerVersionArn > /dev/null  
else 
  echo "No updating of lambda layer"
fi

