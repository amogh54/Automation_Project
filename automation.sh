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

#Copy the log files to S3 Bucket
if [ -f "/tmp/$name-httpd-logs-$Date.tar" ]; then
        aws s3 cp  /tmp/$name-httpd-logs-$Date.tar s3://$s3_bucket
        rm -rfv /tmp/$name-httpd-logs-$Date.tar                       #Remove tar files once copied to S3

fi
