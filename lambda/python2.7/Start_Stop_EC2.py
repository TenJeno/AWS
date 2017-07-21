from __future__ import print_function

import boto3
import json
import urllib
import urllib2
import os
import uuid

def lambda_handler(event, context):

    defaultregion = os.environ['AWS_DEFAULT_REGION']

    # Get the required information or setup defaults
    #tag = 'ScheduledByLambda'
    try:
        print(os.environ['ScheduledByLambdaTag'])
        enableschedule = os.environ['ScheduledByLambdaTag']
    except KeyError:
        print('Please provide an environment variable for "ScheduledByLambda" with a value to check EC2 Instances for.')

    try:
        print(os.environ['Vpc_Id'])
    except KeyError:
        print('Please provide the environment variable "Vpc_Id", with the appropriate value to narrow down the EC2 search specification.')

    try:
        print(os.environ['Region'])
        region = (os.environ['Region'])
    except KeyError:
        print('The "Region" environment variable was not specified. Using the default region ' + str(defaultregion) + ".")

    try:
        print(os.environ['Operation'])
        operation = (os.environ['Operation'])
    except KeyError:
        print('Please provide the environment variable "Operation" with the appropriate value, either "Start" or "Stop".')

    # Generate the GUID for the AWS Next page token
    # guid = str(uuid.uuid1())
    # print('Next result set guid = ' + guid)

    # Get the IP Addresses of the required instances as determined by the filter

    if operation == "Stop":
        ec2client = boto3.client('ec2', region_name=region)
        response = ec2client.describe_instances(
            DryRun=False,
            Filters=[
                {
                    'Name': 'tag:%s' % enableschedule,
                    'Values': [
                        'true',
                        'yes'
                    ]
                },
                {
                    'Name': 'instance-state-name',
                    'Values': [
                        'running'
                    ]
                }
            ]
        )

    if operation == "Start":
        ec2client = boto3.client('ec2', region_name=region)
        response = ec2client.describe_instances(
            DryRun=False,
            Filters=[
                {
                    'Name': 'tag:%s' % enableschedule,
                    'Values': [
                        'true',
                        'yes'
                    ]
                },
                {
                    'Name': 'instance-state-name',
                    'Values': [
                        'stopped'
                    ]
                }
            ]
        )

    if operation == "Stop":
        for instance in response:
            print('Stopping ' + str(instance.id) + ".")
            ec2client.instances.filter(InstanceIds=instance.id).stop()

    if operation == "Start":
        for instance in response:
            print('Starting ' + str(instance.id) + ".")
            ec2client.instances.filter(InstanceIds=instance.id).start()


    return event
