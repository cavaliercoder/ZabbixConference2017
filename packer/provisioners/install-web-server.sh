#!/bin/bash
yum install -y httpd lynx
install -o root -g root -m 0644 /tmp/index.html /var/www/html/index.html
systemctl enable httpd
systemctl start httpd
