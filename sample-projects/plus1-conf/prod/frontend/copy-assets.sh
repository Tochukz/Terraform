cd ../../../react-app
# git checkout master
npm run build 
aws s3 sync build/ s3://plus1-conf-prod-assets