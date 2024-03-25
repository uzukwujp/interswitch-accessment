terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  //access_key =  AWS_ACCESS_KEY_ID
 // secret_key = AWS_SECRET_ACCESS_KEY
}

#Create VPC
resource "aws_vpc" "my-vpc-02" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "my-vpc-02"         
  }
}

# Subnet 1
resource "aws_subnet" "Public-Subnet-1" {
  vpc_id     = aws_vpc.my-vpc-02.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public-Subnet-1"
  }
}

# Subnet 2
resource "aws_subnet" "Public-Subnet-2" {
  vpc_id     = aws_vpc.my-vpc-02.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public-Subnet-2"
  }
}

# Subnet 3
resource "aws_subnet" "Private-Subnet-1" {
  vpc_id     = aws_vpc.my-vpc-02.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private-Subnet-1"
  }
}

# Subnet 4
resource "aws_subnet" "Private-Subnet-2" {
  vpc_id     = aws_vpc.my-vpc-02.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private-Subnet-2"
  }
}

#Internet-gateway
resource "aws_internet_gateway" "my-internet-gateway" {
  vpc_id = aws_vpc.my-vpc-02.id

  tags = {
    Name = "my-internet-gateway"
  }
}



# Created a Routes-Table
resource "aws_route_table" "Public-Route-Table" {
   vpc_id     = aws_vpc.my-vpc-02.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.Public-Route-Table.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

#Public-subnet-1-association
resource "aws_route_table_association" "Public-subnet-1-association" {
  subnet_id      = aws_subnet.Public-Subnet-1.id
  route_table_id = aws_route_table.Public-Route-Table.id
}

resource "aws_route_table_association" "Public-subnet-2-association" {
  subnet_id      = aws_subnet.Public-Subnet-2.id
  route_table_id = aws_route_table.Public-Route-Table.id
}



resource "aws_nat_gateway" "Private-Subnet-1-NAT" {
  allocation_id = aws_eip.my-internet-gateway.id
  subnet_id     = aws_subnet.Private-subnet-1.id

  tags = {
    Name = "Private-Subnet-1-NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my-internet-gateway]
}


resource "aws_nat_gateway" "Private-Subnet-2-NAT" {
  allocation_id = aws_eip.Private-Subnet-2-NAT.id
  subnet_id     = aws_subnet.Private-subnet-2.id

  tags = {
    Name = "Private-Subnet-2-NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my-internet-gateway]
}



# Created a Routes-Table for the Private-route-Table
resource "aws_route_table" "Private-subnet-1-rtb" {
   vpc_id     = aws_vpc.my-vpc-02.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Private-Subnet-1-NAT.id
  }

#   route {
#     ipv6_cidr_block        = "::/0"
#     egress_only_gateway_id = aws_egress_only_internet_gateway.Public-Route-Table.id
#   }

  tags = {
    Name = "Private-subnet-1-rtb"
  }
}



# Created a Routes-Table for the Private-route-Table
resource "aws_route_table" "Private-subnet-2-rtb" {
   vpc_id     = aws_vpc.my-vpc-02.id

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Private-Subnet-1-NAT.id
  }

#   route {
#     ipv6_cidr_block        = "::/0"
#     egress_only_gateway_id = aws_egress_only_internet_gateway.Public-Route-Table.id
#   }

  tags = {
    Name = "Private-subnet-2-rtb"
  }
}

resource "aws_security_group" "POC-SG" {
  name        = "POC-SG"
  description = "Security group allowing ports 80"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





#ECS SET UP

resource "aws_ecs_cluster" "POC-Assesment1" {
  name = "white-hart"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


# module "ecs_cluster" {
#   source = "terraform-aws-modules/ecs/aws//modules/cluster"

#   cluster_name = "POC-Assesment1"

#   cluster_configuration = {
#     execute_command_configuration = {
#       logging = "OVERRIDE"
#       log_configuration = {
#         cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
#       }
#     }
#   }

#   fargate_capacity_providers = {
#     FARGATE = {
#       default_capacity_provider_strategy = {
#         weight = 50
#       }
#     }
#     FARGATE_SPOT = {
#       default_capacity_provider_strategy = {
#         weight = 50
#       }
#     }
#   }

#   tags = {
#     Environment = "Development"
#     Project     = "EcsEc2"
#   }
# }


# TASK Defination file
resource "aws_ecs_task_definition" "poc-Assesment" {
  family                = "poc-Assesment"
  container_definitions = <<TASK_DEFINITION
[
  {
    "cpu": 10,
    "command": ["sleep", "10"],
    "entryPoint": ["/"],
    "environment": [
      {"name": "VARNAME", "value": "VARVAL"}
    ],
    "essential": true,
    "image": "hashicorp/http-echo",
    "memory": 128,
    "name": "hashicorp/http-echo",
    "portMappings": [
      {
        "containerPort": 5678,
        "hostPort": 5678
      }
    ],
        "resourceRequirements":[
            {
                "type":"InferenceAccelerator",
                "value":"device_1"
            }
        ]
  }
]
TASK_DEFINITION

  inference_accelerator {
    device_name = "device_1"
    device_type = "eia1.medium"
  }
}



# service  defination
resource "aws_ecs_service" "Poc-Assessment" {
  name            = "Poc-Assessment"
  cluster         = aws_ecs_cluster.POC-Assesment1.id
  task_definition = aws_ecs_task_definition.poc-Assesment.arn
  desired_count   = 2
 // iam_role        = aws_iam_role.foo.arn
  //depends_on      = [aws_iam_role_policy.foo]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
 
network_configuration {
    subnets          = [aws_subnet.Private-Subnet-1.id,  aws_subnet.Private-Subnet-2.id] 
     security_groups  = [aws_security_group.POC-SG.id]
    assign_public_ip = true #
  }


  load_balancer {
    //target_group_arn = aws_lb_target_group.foo.arn
    container_name   = "hashicorp/http-echo"
    container_port   = 80
    
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  }
}

