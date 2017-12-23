#!/bin/bash

cd /usr/share/elasticsearch/
sudo bin/elasticsearch-plugin install --batch discovery-ec2
sudo bin/elasticsearch-plugin install --batch repository-s3

