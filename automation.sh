#!/bin/bash
name="Amogh"
Date=`date '+%d%m%Y-%H%M%S'`
s3_bucket="upgrad-amogh"

sudo apt update

install_package=`dpkg --get-selections apache2 | awk '{print $1}'`

if [ "$install_package" != "apache2" ]; then
        apt-get install -y apache2
        systemctl start apache2
        systemctl enable apache2
        echo "Apache2 install successfully"
else
        echo "Apache22 already installed"
fi

serv_start=`systemctl status apache2 | grep Active | tr -s " " | cut -d " " -f 3`
if [ "$serv_start" != "active" ];then
        systemctl start apache2
        echo "Apache2 service is installed and running"
else
        echo "Apache2 service already active"

fi

serv_enable=`systemctl is-enabled apache2`
if [ "$serv_enable" != "enabled" ];then
        systemctl enable apache2
else
        echo "Apache2 service already enabled"
fi

awsc=`dpkg --get-selections awscli | awk '{ print$1 }'`
if [ "awsc" != "awscli" ]; then
        apt-get install -y awscli

fi

##CREATING ARCHIVE
cd /var/log/apache2
tar cvfz /tmp/$name-httpd-logs-$Date.tar  *.log
size=`du -sch /tmp/$name-httpd-logs-$Date.tar |head -n 1 | awk '{ print$1 }'`

#Copy the log files to S3 Bucket
if [ -f "/tmp/$name-httpd-logs-$Date.tar" ]; then
        aws s3 cp  /tmp/$name-httpd-logs-$Date.tar s3://$s3_bucket

fi

#BookKeeping

path=/var/www/html/inventory.html

if [ -f "$path" ]; then
        echo "Inventory file exists"
else
        touch /var/www/html/inventory.html
        echo -e "\nLog Type\t\t\tTime Created\t\tType\t\tSize" >  /var/www/html/inventory.html

fi

if [ -f "$path" ]; then
        echo -e "\n$name-httpd-logs\t\t$Date\t\ttar\t\t$size">> /var/www/html/inventory.html


fi

cron=/etc/cron.d/automation
if [ -f "$cron" ]; then
        echo "Cron Already Set"
else
        echo "30 00 * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
        echo "Cron Successfully Set"

fi

#Remove tar file
rm -rfv /tmp/$name-httpd-logs-$Date.tar
