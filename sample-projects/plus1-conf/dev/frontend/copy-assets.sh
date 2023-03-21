cd ../../../react-app
npm run build 
aws s3 sync build/ s3://plus1-conf-dev-assets