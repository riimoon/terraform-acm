#!/bin/bash
sudo apt-get update
sudo apt install apache2 -y
systemctl start apache2
echo "This is my web page" > /var/www/html/index.html