#!/bin/bash
aws sqs receive-message --queue-url $SQS_QUEUE --attribute-names All --message-attribute-names All --max-number-of-messages 1 --region $REGION | jq '.Messages[].Body |=  fromjson | .Messages[].Body.Message |= fromjson' > sqsMessage.json
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
MSG_RECEIPTHANDLE=$(cat sqsMessage.json | jq '.Messages[].ReceiptHandle')
MSG_HOOKFOUND=$(cat sqsMessage.json | jq '.Messages[].Body.Message | has(."LifecycleActionToken")')
MSG_HOOKTOKEN=$(cat sqsMessage.json | jq '.Messages[].Body.Message.LifecycleActionToken')
MSG_HOOKNAME=$(cat sqsMessage.json | jq '.Messages[].Body.MessageLifecycleHookName')
MSG_INSTANCE=$(cat sqsMessage.json | jq '.Messages[].Body.Message.EC2InstanceId')
MSG_ASGNAME=$(cat sqsMessage.json | jq '.Messages[].Body.AutoScalingGroupName')
INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
IPV4=$(wget -q -O - http://169.254.169.254/latest/meta-data/public-ipv4)
REGION=$(wget -q -O - http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')
ROUTE53_ZONE=$(aws ec2 describe-tags --region $REGION | jq -r '.Tags[]|select(.Key=="dns_zone")|select(.ResourceId==$INSTANCEID)|.Value' --arg INSTANCEID  $INSTANCE_ID)
ROUTE53_RECORD=$(aws ec2 describe-tags --region $REGION | jq -r '.Tags[]|select(.Key=="dns_record")|select(.ResourceId==$INSTANCEID)|.Value' --arg INSTANCEID  $INSTANCE_ID)
SQS_QUEUE=$(aws ec2 describe-tags --region $REGION | jq -r '.Tags[]|select(.Key=="sqs_queue")|select(.ResourceId==$INSTANCEID)|.Value' --arg INSTANCEID  $INSTANCE_ID)
INSTANCE_RECORD=$(wget -q -O - http://169.254.169.254/latest/meta-data/public-hostname)
echo "{}" |jq '.+{"Comment": "A new record set for the zone.","Changes": [{"Action": "UPSERT","ResourceRecordSet": {"Name": $ROUTE53RECORD,"Type": "CNAME", "SetIdentifier": $INSTANCEID,"Weight": 1,"TTL": 60,"ResourceRecords": [{"Value": $INSTANCERECORD}]}}]}' --arg INSTANCEID $INSTANCE_ID --arg INSTANCERECORD $INSTANCE_RECORD. --arg ROUTE53RECORD $ROUTE53_RECORD > Route53CName.json
echo "{}" |jq '.+{"Comment": "A new record set for the zone.","Changes": [{"Action": "DELETE","ResourceRecordSet": {"Name": $ROUTE53RECORD,"Type": "CNAME", "SetIdentifier": $INSTANCEID,"Weight": 1,"TTL": 60,"ResourceRecords": [{"Value": $INSTANCERECORD}]}}]}' --arg INSTANCEID $INSTANCE_ID --arg INSTANCERECORD $INSTANCE_RECORD. --arg ROUTE53RECORD $ROUTE53_RECORD > delRoute53CName.json
if [[ $MSG_HOOKFOUND = true && $MSG_INSTANCE = $INSTANCE_ID &&  $MSG_HOOKNAME = autoscaling:EC2_INSTANCE_LAUNCHING ]]; then aws autoscaling record-lifecycle-action-heartbeat --lifecycle-action-token $MSG_HOOKTOKEN --lifecycle-hook-name $MSG_HOOKNAME --auto-scaling-group-name $MSG_ASGNAME; aws route53 change-resource-record-sets --hosted-zone-id Z1Q256JEOFMLZY --change-batch file://Route53CName.json; aws autoscaling complete-lifecycle-action --lifecycle-action-result CONTINUE --lifecycle-action-token $MSG_HOOKTOKEN --lifecycle-hook-name $MSG_HOOKNAME --auto-scaling-group-name $MSG_ASGNAME; aws sqs delete-message --queue-url $SQS_QUEUE --receipt-handle $MSG_RECEIPTHANDLE --region $REGION; elif [[ $MSG_HOOKFOUND = true && $MSG_HOOKNAME = autoscaling:EC2_INSTANCE_TERMINATING ]]; then aws autoscaling record-lifecycle-action-heartbeat --lifecycle-action-token $MSG_HOOKTOKEN --lifecycle-hook-name $MSG_HOOKNAME --auto-scaling-group-name $MSG_ASGNAME --region $REGION; aws route53 change-resource-record-sets --hosted-zone-id $ROUTE53_ZONE --change-batch file://delRoute53CName.json; aws autoscaling complete-lifecycle-action --lifecycle-action-result CONTINUE --lifecycle-action-token $MSG_HOOKTOKEN --lifecycle-hook-name $MSG_HOOKNAME --auto-scaling-group-name $MSG_ASGNAME; aws sqs delete-message --queue-url $SQS_QUEUE --receipt-handle $MSG_RECEIPTHANDLE --region $REGION; fi; 
