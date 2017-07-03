#!/bin/bash
function aws-list-instances() {
  aws ec2 describe-instances $@ \
    | jq -rM '.Reservations[].Instances[] | .InstanceId + ", " + (.Tags[] | select(.Key=="Name") | .Value) + ", " + .PublicIpAddress'
}

function aws-kinesis-dump() {
  SHARD_ITERATOR=$(aws kinesis get-shard-iterator --shard-id shardId-000000000000 --shard-iterator-type TRIM_HORIZON --stream-name $1 --query 'ShardIterator')
  aws kinesis get-records --shard-iterator $SHARD_ITERATOR | jq .
}
