import json
import urllib.parse


def _get_prefix(key):
    indexes = [i for i, backslash in enumerate(key) if backslash == "/"]
    return key[:indexes[-1] + 1]


def lambda_handler(event, context):
    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    full_path = "{}/{}".format(bucket, key)
        
    message = {
        "full_path": full_path,
        "prefix": _get_prefix(full_path),
    }
    return message
    
