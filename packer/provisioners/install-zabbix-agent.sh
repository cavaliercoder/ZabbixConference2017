#!/bin/bash

#
# Install Zabbix Agent and tools
#
rpm -q zabbix-release || \
  rpm -i http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum install -y \
    zabbix-agent \
    zabbix-get \
    zabbix-sender

#
# Fix re: https://support.zabbix.com/browse/ZBX-10542
#
cat > zabbix_agent_fix.te <<MODULE
module zabbix_agent_fix 1.0;

require {
    type zabbix_agent_t;
    class process setrlimit;
}

#============= zabbix_agent_t ==============
allow zabbix_agent_t self:process setrlimit;

MODULE

checkmodule -m -M zabbix_agent_fix.te -o zabbix_agent_fix.mod
semodule_package -m zabbix_agent_fix.mod -o zabbix_agent_fix.pp
semodule -i zabbix_agent_fix.pp

#
# Start Zabbix Agent
#
systemctl enable zabbix-agent
systemctl start zabbix-agent
