#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>Hallo $myip</h1><br>by terraform" > /var/www/html/index.html  
