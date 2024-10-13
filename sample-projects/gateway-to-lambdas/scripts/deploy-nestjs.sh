#!/bin/bash
# Filename: deploy-nestjs.sh
# Description: Deploys NestJS application code to S3 bucket as Lambda function handler and updates the Lambda fucnction.
# To upload build to S3 and also update the lambda function: ./deploy-nestjs.sh 0.0.1 dev app_name
# To upload build to S3 only WITHOUT updating the lambda functions: ./deploy-nestjs.sh 0.0.1 dev app_name --nofunc
# To upload and deploy only lambda function but not the layer, ./deploy-nestjs.sh 0.0.1 dev app_name --nolayer

version=$1
env=$2
app_name=$3
fourth=$4
if test -z "$version"
then
  echo "Please supply a version number as the first argument for the script e.g ./deploy-nestjs.sh 0.0.1 prod clinic --nolayer | --nofunc"
  exit
fi 

if test -z "$app_name"
then
  echo "Please supply a app_name as the second argument for the script e.g ./deploy-nestjs.sh 0.0.1 dev identity  --nolayer | --nofunc"
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

case $app_name in 
  identity)
    code_path=identity-server
    code_dir=identity
    LambdaPrefix=Identity
    ;;
  clinic)
    code_path=clinic/clinic-server
    code_dir=clinic
    LambdaPrefix=Clinic
    ;;
  iclinic)
    code_path=iclinic/iclinic-server
    code_dir=iclinic
    LambdaPrefix=IClinic
    ;;
  portal)
    echo "Not yet supported!"
    exit
    ;;
  *)
    echo -m "Unknown lambda "
    exit
    ;;
esac

case $fourth in 
  --nofunc)
    nofunc=$fourth
    ;;
  --nolayer)
    nolayer=$fourth
    ;;
esac

echo "Code path: $code_path"
echo "Dist path: $dist_path"
echo "LambdaPrefix: $LambdaPrefix"

echo Version=$version

cd ../../$code_path
yarn install
yarn build
zip -r ${code_dir}.zip dist

if [ -z "$nolayer" ] 
then
  mkdir nodejs
  cp package.json nodejs/
  cd nodejs
  yarn install --production=true
  cd ../
  zip -q -r ${code_dir}_nodejs.zip nodejs
else
  echo "No packaging of node_modules"
fi


echo "Copying $code_dir.zip to S3 bucket with key: v$version/$code_dir.zip" 
aws s3 cp $code_dir.zip s3://firdmedical-$env-deployment-artifacts/v$version/$code_dir.zip 

if [ -z "$nolayer" ]; then
  echo "Copying ${code_dir}_nodejs.zip to S3 bucket with key: v$version/${code_dir}_nodejs.zip" 
  aws s3 cp ${code_dir}_nodejs.zip s3://firdmedical-$env-deployment-artifacts/v$version/${code_dir}_nodejs.zip 
else 
  echo "No updating of node_modules S3 object"
fi

if [ -z "$nofunc" ] 
then
  echo "Updating lambda function..."
  aws lambda update-function-code --function-name FirdMedicals${LambdaPrefix}_${prefix} --s3-key v$version/$code_dir.zip --s3-bucket firdmedical-${env}-deployment-artifacts > /dev/null

  rm -r $code_dir
  rm $code_dir.zip
else
  echo "No updating of lambda functions!"
  rm -r $code_dir
  rm $code_dir.zip
  echo "S3 copying completed!"
fi

if [ -z "$nolayer" ]; then
  echo "Publishing lambda layer version..."
  LayerVersionArnWithQuotes=$(aws lambda publish-layer-version --layer-name FirdMedicals${LambdaPrefix}_${prefix} --content S3Bucket=firdmedical-${env}-deployment-artifacts,S3Key=v$version/${code_dir}_nodejs.zip --query LayerVersionArn)
  LayerVersionArn=$(sed -e 's/^"//' -e 's/"$//' <<<"$LayerVersionArnWithQuotes") 
  echo "LayerVersionArn=${LayerVersionArn}"

  rm -r nodejs
  rm ${code_dir}_nodejs.zip

  echo "Updating lambda configuration..."
  aws lambda update-function-configuration --function-name FirdMedicals${LambdaPrefix}_${prefix}  --layers $LayerVersionArn > /dev/null  
else 
  echo "No updating of lambda layer"
fi












