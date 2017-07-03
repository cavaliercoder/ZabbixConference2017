#!/bin/bash
yum update -y

#
# disable selinux
# see: https://support.zabbix.com/browse/ZBX-10542
#
cat > /etc/selinux/config <<EOL
SELINUX=permissive
SELINUXTYPE=targeted
EOL
setenforce Permissive

#
# install zabbix and mysql
#
rpm -i http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum install -y \
    mariadb-server \
    vim-enhanced \
    zabbix-agent \
    zabbix-get \
    zabbix-sender \
    zabbix-server-mysql \
    zabbix-web-mysql

#
# configure database
#
sudo systemctl enable mariadb
sudo systemctl start mariadb
mysql <<EOL
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
EOL
zcat /usr/share/doc/zabbix-server-mysql-3.2.*/create.sql.gz | \
    mysql -uzabbix -pzabbix zabbix

#
# configure server
#
cat >> /etc/zabbix/zabbix_server.conf <<EOL
DBPassword=zabbix
EOL
systemctl enable zabbix-server
systemctl start zabbix-server

#
# configure web server
#
# TODO: use /etc/httpd/conf.d/zabbix.conf
cat > /etc/php.d/timezone.ini <<EOL
; set date.timezone
date.timezone=Australia/Perth
EOL

cat > /etc/zabbix/web/zabbix.conf.php <<EOL
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = 'localhost';
\$DB['PORT']     = '0';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'zabbix';
\$DB['PASSWORD'] = 'zabbix';

// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';

\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = 'Demo';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOL

setsebool -P httpd_can_connect_zabbix on

systemctl enable httpd
systemctl start httpd
