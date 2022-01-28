import json
import logging
import os

import boto3

logger = logging.getLogger()

step_functions = boto3.client('stepfunctions')
step_function_arn = os.environ['step_function_arn']


def lambda_handler(event, context):
    message = event['Records'][0]['Sns']['Message']
    full_path = json.loads(message)['responsePayload']['full_path']
    prefix = json.loads(message)['responsePayload']['prefix']
    logger.info(f"New file : {full_path}")

    response = step_functions.start_execution(
        stateMachineArn=step_function_arn,
        input=json.dumps(
            {
                'full_path': full_path,
                'prefix': prefix,
            },
            )
    )
    logger.info(str(response))

    return True
