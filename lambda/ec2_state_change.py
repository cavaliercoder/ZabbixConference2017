"""
Lambda expression to update Zabbix Host configuration when the state of the
associated AWS EC2 Instance changes.
"""

import logging
import json
from os import environ
from sys import exc_info
from re import sub
from base64 import b64decode
import boto3
import zabbops

logger = logging.getLogger("zabbops")
if environ.get('DEBUG'):
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)

def cloudwatch_event_handler(event, context):
    """
    This handler accepts CloudWatch Events when an EC2 Instances changes state.
    The associated Host is then updated in Zabbix via the API.
    """

    ret = {'message': 'Nothing to do'}
    logger.debug('Received event: {}'.format(json.dumps(event)))

    # read event details
    event_state = event['detail']['state']
    instanceid = event['detail']['instance-id']
    logger.info("Instance %s changed state to: %s", instanceid, event_state)

    # get instance details from AWS API
    ec2 = boto3.client('ec2')
    response = ec2.describe_instances(InstanceIds=[instanceid])
    logger.debug('ec2.describe_instances({}): {}'.format(instanceid, json.dumps(response, default=str)))

    try:
        instance = response['Reservations'][0]['Instances'][0]
    except IndexError:
        return {
            'message': 'Instance not found: {}'.format(instanceid)
        }

    state = instance['State']['Name']
    if state != event_state:
        logger.warn('Event state \'{}\' does not match Instance state \'{}\''.format(
            event_state, state))

    if state == 'pending' or state == 'running':
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
                                                    enabled=True,
                                                    groups=groups,
                                                    templates=templates)

    elif state == 'terminated':
        # archive a terminated Zabbix Host
        ret = zabbops.Configurator().archive_host(
            instance,
            reason='Lambda triggered by instance termination')

    logger.info(ret['message'])
    return ret

# wrap handler for use with Kinesis Streams
kinesis_stream_handler = zabbops.KinesisStreamHandler(cloudwatch_event_handler)
