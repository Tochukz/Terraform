#!/bin/bash
# Filename: userdata.sh
# Task: Install dependencies for backend

echo OS Version: 
cat /etc/os-release

sudo yum update -y

## Install Nginx
sudo amazon-linux-extras install nginx1 -y
sudo service nginx start

# Enable Nginx to start at Boot time
sudo chkconfig nginx o
