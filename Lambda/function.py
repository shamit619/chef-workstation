import boto3
from botocore.vendored import requests
import paramiko

def lambda_handler(event, context):

    s3_client = boto3.client('s3')
    s3_client.download_file('kapil1527','key.pem', '/tmp/key.pem')
    k = paramiko.RSAKey.from_private_key_file("/tmp/key.pem")
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    event = {"IP":"54.205.87.5"}
    host=event["IP"]
    print ("Connecting to " + host)
    c.connect( hostname = host, username = "ec2-user", pkey = k )
    print ("Connected to " + host)

    commands = [
        "sh lambda.sh"
        ]
        
    for command in commands:
        print ("Executing {}".format(command))
        stdin , stdout, stderr = c.exec_command(command)
        print (stdout.read())
        print (stderr.read())

    return {"statusCode": 200, \
        "headers": {"Content-Type": "application/json"}, \
        "body": "{\"Chef-Server already created \": }"}
