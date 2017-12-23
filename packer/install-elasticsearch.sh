#!/bin/bash

# Get the PGP Key
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list

apt-get update
if [ -z "$ES_VERSION" ]; then
    echo "Installing the latest Elasticsearch version"
    sudo apt-get install elasticsearch
else
    echo "Installing Elasticsearch version $ES_VERSION"
    sudo apt-get install elasticsearch=$ES_VERSION
fi

cd /usr/share/elasticsearch/
sudo bin/elasticsearch-plugin install --batch x-pack
cd -

sudo mv elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
