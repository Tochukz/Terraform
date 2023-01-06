#!/bin/bash
sudo amazon-linux-extras install nginx1 -y 
sudo service nginx start

mkdir -p apps/book-api
dotenv=apps/book-api/.env 
touch $dotenv

echo PORT=${server_port} >> $dotenv
echo DB_HOST=${db_address} >> $dotenv
echo DB_PORT=${db_port} >> $dotenv

echo "<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>PORT = ${server_port}</p>
<p>DB_HOST =${db_address}</p>
<p>DB_PORT=${db_port}</p>
<p><em>Thank you for using nginx.</em></p>
</body>
</html>
" | sudo tee /usr/share/nginx/html/index.html 