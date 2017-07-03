"""
Tests for zabbops module
"""

import unittest
import ec2_state_change

EVENT = {
    'Records': [{
        'eventVersion': '1.0',
        'eventID': 'shardId-000000000000:49574708659922778835777437618543707076771245399023288322',
        'invokeIdentityArn': 'arn:aws:iam::842183664555:role/ZabbixDemoRole',
        'eventName': 'aws:kinesis:record',
        'eventSourceARN': 'arn:aws:kinesis:ap-southeast-2:842183664555:stream/ZabbixDemoKinesisStream',
        'eventSource': 'aws:kinesis',
        'awsRegion': 'ap-southeast-2',
        'kinesis': {
            'approximateArrivalTimestamp': 1498990943.379,
            'partitionKey': 'f172a731-1c0a-43f4-af23-a88196ffd4a1_07a3f7b5-34ec-45f8-bda3-cb09580167a0',
            'data': 'eyJ2ZXJzaW9uIjoiMCIsImlkIjoiZjE3MmE3MzEtMWMwYS00M2Y0LWFmMjMtYTg4MTk2ZmZkNGExIiwiZGV0YWlsLXR5cGUiOiJFQzIgSW5zdGFuY2UgU3RhdGUtY2hhbmdlIE5vdGlmaWNhdGlvbiIsInNvdXJjZSI6ImF3cy5lYzIiLCJhY2NvdW50IjoiODQyMTgzNjY0NTU1IiwidGltZSI6IjIwMTctMDctMDJUMTA6MjI6MjJaIiwicmVnaW9uIjoiYXAtc291dGhlYXN0LTIiLCJyZXNvdXJjZXMiOlsiYXJuOmF3czplYzI6YXAtc291dGhlYXN0LTI6ODQyMTgzNjY0NTU1Omluc3RhbmNlL2ktMDUyMWI3ZmQ0MWVmZDNhNGEiXSwiZGV0YWlsIjp7Imluc3RhbmNlLWlkIjoiaS0wNTIxYjdmZDQxZWZkM2E0YSIsInN0YXRlIjoic2h1dHRpbmctZG93biJ9fQ==',
            'kinesisSchemaVersion': '1.0',
            'sequenceNumber': '49574708659922778835777437618543707076771245399023288322'
        },
    }]
}

class KinesisStreamTests(unittest.TestCase):
    """
    Tests for the Kinesis Stream handler.
    """

    def test_001_read_batch(self):
        ret = ec2_state_change.kinesis_stream_handler(EVENT, None)
        self.assertIsNotNone(ret)
        self.assertEqual(ret['message'],'this')
