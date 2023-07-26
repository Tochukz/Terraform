# Update repository 
sudo apt update -y

# Install utility
sudo apt-get install unzip -y

# Install Nginx 
sudo apt install nginx -y
# sudo ufw allow 'Nginx HTTP' -y
# sudo service nginx start
# Learn more: https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-22-04

# Install docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo systemctl status docker
# To avoid using sudo any time you run the docker command 
sudo usermod -aG docker ubuntu
#Learn more: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04