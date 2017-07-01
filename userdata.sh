#!/bin/bash

# install zabbix
rpm -i http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum install -y
    zabbix-agent \
    zabbix-get \
    zabbix-sender \
    zabbix-server-mysql
