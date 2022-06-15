from typing import Iterator
import boto3
import requests
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


s3 = boto3.client('s3')
all_buckets = [
    bucket_dict['Name'] for bucket_dict in
    s3.list_buckets()['Buckets']
]

def list_objs(bucket: str) -> Iterator[str]:
    """
    Generator yielding all object names in the bucket. Potentially requires
    multiple requests for large buckets since list_objects is capped at 1000
    objects returned per call.
    """
    response = s3.list_objects_v2(Bucket=bucket)
    while True:
        if 'Contents' not in response:
            # Happens if bucket is empty
            return
        for obj_dict in response['Contents']:
            yield obj_dict['Key']
            last_key = obj_dict['Key']
        if response['IsTruncated']:
            response = s3.list_objects_v2(Bucket=bucket, StartAfter=last_key)
        else:
            return

def is_public(bucket: str, obj: str) -> bool:
    url = f'https://{bucket}.s3.amazonaws.com/{obj}'
    try:
        resp = requests.head(url, verify=False)
        if resp.status_code == 200:
            return True
        elif resp.status_code == 403:
            return False
        else:
            return False
    except:
        return False

public_buckets = set()

print("[ ] Finding open buckets with a quick threshold. Not deep dive.")
for bucket in all_buckets:
    print(f'Checking {bucket}.')
    region = s3.get_bucket_location(Bucket=bucket)['LocationConstraint']
    killCounter = 0
    for obj in list_objs(bucket):
        if is_public(bucket, obj):
            print(f'[+] {bucket}/{obj} is public!')
            public_buckets.add(bucket)
        else:
        	killCounter = killCounter + 1
        	
        if killCounter > 30:
        	break

print("[ ] Finding all objects that are public in the open buckets")
for bucket in public_buckets:
    print(f'Checking {bucket}.')
    for obj in list_objs(bucket):
        if is_public(bucket, obj):
            print(f'[+] {bucket}/{obj} is public!')
        	