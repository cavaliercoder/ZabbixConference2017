"""
Lambda expression to update Zabbix Host configuration when the state of the
associated AWS EC2 Instance changes.
"""

import logging
from re import sub
import boto3
import zabbops

def lambda_handler(event, context):
    """
    Lambda function handler to update a host in Zabbix when its state changes in
    AWS EC2.
    """

    ret = {'message': 'Nothing to do'}

    logger = logging.getLogger("zabbops")
    logger.setLevel(logging.INFO)
    logger.info('Loading module...')

    # read event details
    state = event['detail']['state']
    instanceid = event['detail']['instance-id']
    logger.info("Instance %s changed state to: %s", instanceid, state)

    # get instance details from AWS API
    ec2 = boto3.client('ec2')
    response = ec2.describe_instances(InstanceIds=[instanceid])
    instance = response['Reservations'][0]['Instances'][0]

    if state == 'pending':
        # create a new Zabbix Host
        groups = ['AWS EC2 Instances']

        environment = zabbops.get_tag_by_key(instance, 'Environment')
        if environment:
            groups.append('Environments/' + environment.title())
        else:
            groups.append('Environments/Unknown')

        role = zabbops.get_tag_by_key(instance, 'Role')
        if role:
            role = sub(r'[^a-zA-Z0-9:]+', '', role.title())
            groups.append('Roles/' + role.replace('::', '/'))
        else:
            groups.append('Roles/Unknown')

        templates = ['Template OS Linux']

        ret = zabbops.Configurator().create_host(instance,
                                                 groups=groups,
                                                 templates=templates)

    elif state == 'running':
        # enable a Zabbix Host for monitoring
        ret = zabbops.Configurator().toggle_host(instance)

    elif state == 'terminated':
        # archive a terminated Zabbix Host
        ret = zabbops.Configurator().archive_host(
            instance,
            reason='Lambda triggered by instance termination')

    logger.info(ret['message'])
    return ret
