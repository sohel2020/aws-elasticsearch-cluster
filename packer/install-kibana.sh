#!/bin/bash

# Get the PGP Key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list

sudo apt-get update
if [ -z "$ES_VERSION" ]; then
    echo "Installing latest Kibana version"
    sudo apt-get install kibana
else
    echo "Installing Kibana version $ES_VERSION"
    sudo apt-get install kibana=$ES_VERSION
fi

cd /usr/share/kibana/
sudo bin/kibana-plugin install x-pack
chown kibana:kibana -R *

# This needs to be here explicitly because of a long first-initialization time of Kibana
sudo systemctl daemon-reload
sudo systemctl enable kibana.service
sudo service kibana start

printf 'Install docker ........'
curl -sSL https://get.docker.com | sudo bash
usermod -aG docker ubuntu

printf 'Install elasticserach metric collector ........'
docker pull telenorhealth/es-monitor 


printf 'Waiting for Kibana to initialize...'
until $(curl --output /dev/null --silent --head --fail http://localhost:5601); do
    printf '.'
    sleep 5
done
