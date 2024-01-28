#!/bin/bash

##
## This is a simple bash script to install basic server for a modern docker-first linux server
##
## This scripts updates the system and installs networking tools, docker compose and vim
##

##

set -e

##

reset

clear

##

echo
echo "## "
echo "## routine: [provision-new-ubuntu-linux-server-basic] // state: [starting]"
echo "## "
echo

##

apt-get update

##

apt-get upgrade -y

apt-get dist-upgrade -y

##

apt-get install -y net-tools

##

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    python3-pip


source <(curl -fsSL get.docker.com -o get-docker.sh)

# Linux post-install
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker

##
#https://github.com/aaomidi/certbot-dns-google-domains
echo
echo "## "
echo "## routine: Installing certbot and setting up ssl // state: [starting]"
echo "## "
echo


pip3 install certbot certbot-dns-google-domains

read -p 'dns_google_domains_access_token : ' access_token
echo "dns_google_domains_access_token = $access_token" >> '/var/lib/letsencrypt/dns_google_domains_credentials.ini'

certbot certonly \
-i 'apache' \
--authenticator 'dns-google-domains' \
--dns-google-domains-credentials '/var/lib/letsencrypt/dns_google_domains_credentials.ini' \
--server 'https://acme-v02.api.letsencrypt.org/directory' \
--email 'hishamsaleh@outlook.com' \
--noninteractive \
--agree-tos \
-d '*.hishamsaleh.com' \
-d 'hishamsaleh.com'

echo
echo "## "
echo "## routine: Installing .Net Core from MS  // state: [starting]"
echo "## "
echo


echo 'Package: dotnet* aspnet* netstandard*' >> '/etc/apt/preferences'
echo 'Pin: origin "http://asi-fs-n.contabo.net/"' >> '/etc/apt/preferences'
echo 'Pin-Priority: -10' >> '/etc/apt/preferences'

# Get Ubuntu version
declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)

# Download Microsoft signing key and repository
wget https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb

# Install Microsoft signing key and repository
sudo dpkg -i packages-microsoft-prod.deb

# Clean up
rm packages-microsoft-prod.deb

# Update packages
sudo apt update

apt install dotnet-sdk-8.0

curl -fsSL https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list

#https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-ver16&tabs=ubuntu2204

sudo apt-get update
sudo apt-get install -y mssql-server
sudo /opt/mssql/bin/mssql-conf setup

sudo apt-get install mssql-tools18 unixodbc-dev

echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc

# Enable rewrite module
sudo a2enmod rewrite

# Enable SSL module
sudo a2enmod ssl

# Enable Proxy module
sudo a2enmod proxy_http

sudo a2enmod headers