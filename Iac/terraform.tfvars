aws_access_key           = "your-cloudprovider-app-key"
aws_secret_key           = "your-cloudprovider-secret-key" 
aws_region               = "us-east-1"

vpc_cidr                 = "10.0.0.0/16"
vpc_name                 = "my-vpc-02"

public_subnet_1_cidr     = "10.0.1.0/24"
public_subnet_1_az       = "us-east-1a"

public_subnet_2_cidr     = "10.0.2.0/24"
public_subnet_2_az       = "us-east-1b"

private_subnet_1_cidr    = "10.0.3.0/24"
private_subnet_1_az      = "us-east-1a"

private_subnet_2_cidr    = "10.0.4.0/24"
private_subnet_2_az      = "us-east-1b"

revamp_elb_name          = "poc-accessment-elb"

container_port           =  5678

task_execution_role      =  "arn:aws:iam::062000045886:role/ecsTaskExecutionRole"

