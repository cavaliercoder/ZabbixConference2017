output "configuration" {
  value = <<CONFIGURATION
Zabbix Demo Resources:

  Zabbix server URL:    http://${aws_instance.zabbix_server.public_dns}/zabbix/
  Zabbix server IP:     ${aws_instance.zabbix_server.public_ip}

  Web Server URL:       http://${aws_alb.web_alb.dns_name}

CONFIGURATION
}
