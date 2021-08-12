#aws ecs run-task --task-definition unzip-tf:1 --cluster unzip-cluster --network-configuration 'awsvpcConfiguration={subnets=["subnet-0182c34ab1c06866a"],securityGroups=["sg-0a93aacdbb02c7e51"],assignPublicIp="ENABLED"}' --count 1 --launch-type FARGATE

import boto3
import json

def lambda_handler(event, context):
   client = boto3.client('ecs')
   zip_s3 = "s3://littlejo-unzip/unzip.zip"
   unzip_s3 = "s3://littlejo-unzip/toto/"
   subnets_list = ["${default_subnet}"]
   sg           = "${default_sg}"
   
   response = client.run_task(
       cluster='unzip-cluster',
       count=1,
       launchType='FARGATE',
       networkConfiguration={
           'awsvpcConfiguration': {
               'subnets': subnets_list,
               'securityGroups': [
                   sg,
               ],
               'assignPublicIp': 'ENABLED'
           }
       },
       overrides={
           'containerOverrides': [
               {
                   'name': "unzip",
                   'command': [
                       'unzip-s3.sh',
                       zip_s3,
                       unzip_s3,
                   ],
               },
           ],
       },
       platformVersion='1.4.0',
       taskDefinition='unzip-tf:1'
   )
   return {
       'statusCode': 200,
       'body': json.dumps('Hello from Lambda!')
   }
