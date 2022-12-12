#%%%%%%%%%%%%%%%%
#%
#% Iris EC2 Installer
#% v0.0.1
#% written by driemworks
#%
#% A script to install Iris on an EC2 running the Amazon Linux 2 AMI.
#% This script will install IPFS, Docker, Nginx, and Iris and enable 
#% each as system services.
#%
#%%%%%%%%%%%%%%%%%

echo "Iris EC2 Installer V1.0.0"
echo "Ideal Labs, 2022"

echo "STAGE 1: Update packages"
# update instance
sudo yum update -y
sudo yum upgrade -y

cd ~

echo "STAGE 2: Install and Configure IPFS"
# install IPFS (kubo)
wget https://dist.ipfs.io/kubo/v0.16.0/kubo_v0.16.0_linux-amd64.tar.gz
tar -xvzf kubo_v0.16.0_linux-amd64.tar.gz
cd kubo
sudo ./install.sh
ipfs --version

# Cleanup
cd ~
rm kubo_v0.16.0_linux-amd64.tar.gz

# configure IPFS
ipfs init
ipfs config Addresses.API "/ip4/0.0.0.0/tcp/5001"
ipfs config Addresses.Gateway "/ip4/0.0.0.0/tcp/8080"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "[\"*\"]"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Credentials "[\"true\"]"

# setup as a service
# fetch the ipfs.service file
wget https://raw.githubusercontent.com/ideal-lab5/iris-docs/master/src/resources/scripts/ipfs.service
# copy to proper location
sudo mv ipfs.service /etc/systemd/system/ipfs.service

# setup as a service
# to enable the service on startup
sudo systemctl enable ipfs
# to start the service
sudo systemctl start ipfs
# verify ipfs is running
sudo systemctl status ipfs

echo "STAGE 3: Install and Configure Docker"
# install docker
sudo yum install docker
# add group membership for default user 
# (can avoid using `sudo docker ...` later (e.g. in a script))
sudo usermod -a -G docker ec2-user
id ec2-user
newgrp docker
# enable as system service at startup
sudo systemctl enable docker
# start service
sudo systemctl start docker
# verify running
sudo systemctl status docker

# echo "STAGE 4: Install and Configure NGINX"
# sudo amazon-linux-extras install -y nginx1
# enable as system service
# sudo systemctl enable nginx
# start service
# sudo systemctl start nginx

# fetch the chain spec
cd ~
wget https://raw.githubusercontent.com/ideal-lab5/iris/main/iris.json

echo "Complete! Your node is ready to run Iris.)"
