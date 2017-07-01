# Zabbix Conference 2017

This repo contains the working files, slides and demo configurations for my
upcoming talk at [Zabbix Conference 2017](http://www.zabbix.com/conference2017).

You may be interested in my
[previous talk at Zabbix Conference 2016](http://cavaliercoder.com/blog/zabbix-conference-2016.html).

## Usage

1. Install required Python modules

       $ make get-deps

2. Package the Lambda Function

       $ make

3. Provision AWS Infrastructure and upload Lambda Function

       $ terraform apply

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0
International License](http://creativecommons.org/licenses/by-sa/4.0/).
