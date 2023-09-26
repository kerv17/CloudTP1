import boto3

REGION_NAME = "us-east-1"

AMI = "ami-06ae0e97bcb59038c" # Ubuntu 18.04 LTS
aws_access_key_id = 'YOUR_ACCESS_KEY'
aws_secret_access_key = 'YOUR_SECRET_KEY'

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

def createELB(name: str, subnets: list, security_groups: list):
    elbv2 = boto3.client('elbv2',
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        region_name=region_name
    )
    load_balancer_name = name
    listeners = [
        {
            'Protocol': 'HTTP',
            'Port': 80,
            'DefaultActions': [
                {
                    'Type': 'fixed-response',
                    'FixedResponseConfig': {
                        'ContentType': 'text/plain',
                        'StatusCode': '200',
                        'ContentType': 'text/plain',
                        'ContentDescription': 'Hello from the load balancer!'
                    }
                }
            ]
        }
    ]
    response = elbv2.create_load_balancer(
        Name=load_balancer_name,
        Subnets=subnets,
        SecurityGroups=security_groups,
        Scheme='internet-facing',
        Type='application',
        IpAddressType='ipv4'
    )

    for listener in listeners:
    elbv2.create_listener(
        LoadBalancerArn=response['LoadBalancers'][0]['LoadBalancerArn'],
        **listener
    )
    print(f"Load balancer {load_balancer_name} created successfully.")