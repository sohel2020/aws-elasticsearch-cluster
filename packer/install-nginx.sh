#!/bin/bash
set -e

sudo apt-get install nginx apache2-utils -y

sudo mv ~/nginx-client.conf /etc/nginx/nginx.conf
