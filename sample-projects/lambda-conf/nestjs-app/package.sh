
version=$1
if test -z "$version"
then
  echo "Please supply a version number as an argument for the script e.g ./package.sh 1.0.1"
  exit
fi 
echo Version=$version
cd app
npm run build
cp -r node_modules dist/
cp package.json dist/
zip -r dist.zip dist
rm -r dist/node_modules
rm dist/package.json
echo "Coying to S3 bucket with path: v$version/dist.zip" 
aws s3 cp dist.zip s3://tochukwu1-bucket/v$version/dist.zip 