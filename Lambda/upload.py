import boto3
from botocore.vendored import requests
import paramiko
import os

def lambda_handler(event, context):
    #print event['body']
    CookbookName =  event['queryStringParameters']['cookbookName']

    s3_client = boto3.client('s3')
    s3_client.download_file('kapil1527','key.pem', '/tmp/key.pem')
    k = paramiko.RSAKey.from_private_key_file("/tmp/key.pem")
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    event = {"IP":"3.83.189.213"}
    host=event["IP"]
    print ("Connecting to " + host)
    c.connect( hostname = host, username = "ec2-user", pkey = k )
    print ("Connected to " + host)
    cmd = "nohup sudo sh cookbook_upload.sh " + CookbookName + " > /dev/null 2>&1 & "
    print cmd
    stdin , stdout, stderr = c.exec_command(cmd)
    print (stderr.read())
    print "hello"

    return {"statusCode": 200, \
        "headers": {"Content-Type": "application/json"}, \
        "body": "{\"Script execution started. Login to chef server to see updated cookbooks\": }"}
