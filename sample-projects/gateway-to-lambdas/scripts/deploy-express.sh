#!/bin/bash
# Filename: deploy-express.sh
# Description: Deploy Express Application code to S3
# To upload and deploy only lambda function but not the layer, ./deploy-express.sh app-name 0.0.1 prod --nolayer

app_name=$1
version=$2
env=$3
nolayer=$4

if test -z "$app_name"
then
  echo "Please supply a app_name as the first argument for the script e.g ./deploy-express.sh user-management 0.0.1 dev  --nolayer"
  exit
fi

if test -z "$version"
then
  echo "Please supply a version number as the second argument for the script e.g  ./deploy-express.sh user-management 0.0.1 dev  --nolayer"
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

declare -A appToFuncName
appToFuncName["user-management"]="UserManagement"
appToFuncName["catalog-management"]="CatalogManagement"

functName=${appToFuncName[$app_name]}

cd ../../../sample-apps/$app_name
app_zip=$app_name.zip
zip -q -r $app_zip . -x ".*" "node_modules/*" "migrations/*" "resources/*" "seeders/*" "tmp/*" "sql/*" "output/*"

module_zip=${app_name}-nodejs.zip
if [ -z "$nolayer" ]
then
  mkdir nodejs
  cp package.json nodejs/
  cd nodejs
  npm install --omit=dev
  cd ../
  zip -q -r $module_zip nodejs
else
  echo "No packaging of node_modules"
fi

echo "Copying $app_zip to S3 bucket with key: v$version/$app_zip"
aws s3 cp $app_zip s3://chucks-workspace-storage/v$version/$app_zip

echo "Updating lambda function..."
aws lambda update-function-code --function-name $functName --s3-key v$version/$app_zip --s3-bucket chucks-workspace-storage > ${app_name}-lambda-func.json
rm $app_zip

if [ -z "$nolayer" ]; then
  echo "Copying $module_zip to S3 bucket with key: v$version/shared-module.zip"
  aws s3 cp $module_zip s3://chucks-workspace-storage/v$version/shared-module.zip

  echo "Publishing lambda layer version..."
  LayerVersionArnWithQuotes=$(aws lambda publish-layer-version --layer-name SharedLayer --content S3Bucket=chucks-workspace-storage,S3Key=v$version/shared-module.zip --query LayerVersionArn)
  LayerVersionArn=$(sed -e 's/^"//' -e 's/"$//' <<<"$LayerVersionArnWithQuotes")
  echo "LayerVersionArn=${LayerVersionArn}"

  rm -r nodejs
  rm $module_zip

  echo "Updating lambda configuration..."
  aws lambda update-function-configuration --function-name SharedLayer  --layers $LayerVersionArn > /dev/null
else
  echo "No updating of lambda layer"
fi
