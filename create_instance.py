import boto3

REGION_NAME = "us-east-1"

AMI = "ami-06ae0e97bcb59038c" # Ubuntu 18.04 LTS
KEY_NAME = aws_key

def create_instances(instance_type: str, count: int):
    instance_params = {
        'ImageId': AMI,                         # Replace with the desired AMI ID
        'InstanceType': instance_type            # Replace with the desired instance type
        'KeyName': KEY_NAME,        # Replace with your SSH key pair name
        'MinCount': count,
        'MaxCount': count,
    }

    ec2 = boto3.resource('ec2',
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        region_name=region_name
    )

    instances = ec2.create_instances(**instance_params)

    for instance in instances:
        instance.wait_until_running()
        print(f'Instance {instance.id} is running with public IP: {instance.public_ip_address}')
    return instances