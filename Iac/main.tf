
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  #access_key = var.aws_access_key
  #secret_key = var.aws_secret_key
  region     = var.aws_region
}

// VPC
resource "aws_vpc" "my-vpc-02" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

// Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my-vpc-02.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = var.public_subnet_1_az

  tags = {
    Name = "Public-Subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my-vpc-02.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = var.public_subnet_2_az

  tags = {
    Name = "Public-Subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my-vpc-02.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.private_subnet_1_az

  tags = {
    Name = "Private-Subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my-vpc-02.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.private_subnet_2_az

  tags = {
    Name = "Private-Subnet-2"
  }
}

// Internet Gateway
resource "aws_internet_gateway" "my-internet-gateway" {
  vpc_id = aws_vpc.my-vpc-02.id

  tags = {
    Name = "my-internet-gateway"
  }
}

// Route Tables
resource "aws_route_table" "public_route_table" {
   vpc_id = aws_vpc.my-vpc-02.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-internet-gateway.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table_1" {
   vpc_id = aws_vpc.my-vpc-02.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table" "private_route_table_2" {
   vpc_id = aws_vpc.my-vpc-02.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}

// Elastic IPs

resource "aws_eip" "nat_eip_1" {
  domain   = "vpc"
  depends_on = [aws_internet_gateway.my-internet-gateway]
}

resource "aws_eip" "nat_eip_2" {
  domain   = "vpc"
  depends_on = [aws_internet_gateway.my-internet-gateway]
}

// NAT Gateways
resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
}

# Security group for ecs
resource "aws_security_group" "ecs_security_group" {
  name        = "POC-SG"
  description = "Security group allowing ports 80"
  vpc_id      = aws_vpc.my-vpc-02.id
}

resource "aws_security_group_rule" "allow_http_ingress_traffic" {
  security_group_id = aws_security_group.ecs_security_group.id
  from_port         = var.container_port
  to_port           = var.container_port
  type              = "ingress"
  protocol          = "tcp"
  source_security_group_id = aws_security_group.elb_security_group.id
}

resource "aws_security_group_rule" "allow_http_egress_traffic" {
  security_group_id = aws_security_group.ecs_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
  protocol          = "-1"
}

# security group for Loadbalancer

resource "aws_security_group" "elb_security_group" {
  name        = "application-load-balancer"
  description = "Allow http inbound traffic from anywhere"
  vpc_id      = aws_vpc.my-vpc-02.id
}

resource "aws_security_group_rule" "elb_allow_http_ingress_traffic" {
  security_group_id = aws_security_group.elb_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  type              = "ingress"
  protocol          = "tcp"
}

resource "aws_security_group_rule" "elb_allow_http_egress_traffic" {
  security_group_id = aws_security_group.elb_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
  protocol          = "-1"
}



// Load Balancer
resource "aws_lb" "poc-revamp-elb" {
  name               = var.revamp_elb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_security_group.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  
  tags = {
    // Environment = var.tag
  }
}

// Load Balancer Target Group
resource "aws_lb_target_group" "poc_revamp_ecs_containers" {
  name        = "poc-load-balancer-Group"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.my-vpc-02.id
  health_check {
   path = "/"
   healthy_threshold = "3"
   interval = "30"
   protocol = "HTTP"
   matcher = "200"
   timeout = "3"
   unhealthy_threshold = "2"
 }

}

// Load Balancer Listener
resource "aws_lb_listener" "revamp_frontend_landing" {
  load_balancer_arn = aws_lb.poc-revamp-elb.arn
  port              =  80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.poc_revamp_ecs_containers.arn
  }
}

// ECS Cluster

resource "aws_ecs_cluster" "poc_assessment" {
  name = "white-hart"
  configuration {
    execute_command_configuration {
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.frontend_landing_page-apps.name
      }
    }
  }
}


resource "aws_cloudwatch_log_group" "frontend_landing_page-apps" {
  name = "frontend-landing-page-log-group"
}

// ECS Task Definition

resource "aws_ecs_task_definition" "poc_assessment" {
  family = "poc-Assessment"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu       = 256
  memory    = 512
  execution_role_arn = var.task_execution_role
  container_definitions = jsonencode([
    {
      name      = "hashicorp-http-echo-container"
      image     = "hashicorp/http-echo"
      essential = true
      logConfiguration = { 
            logDriver = "awslogs",
            options = { 
               "awslogs-group" : "${aws_cloudwatch_log_group.frontend_landing_page-apps.name}",
               "awslogs-region": "${var.aws_region}",
               "awslogs-stream-prefix": "ecs"
            }
         },
      portMappings = [
        {
          containerPort = var.container_port
        }
      ]
    } 
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

// ECS Service
resource "aws_ecs_service" "poc_assessment_service" {
  name            = "Poc-Assessment"
  cluster         = aws_ecs_cluster.poc_assessment.name
  task_definition = aws_ecs_task_definition.poc_assessment.arn
  desired_count   = 2
  launch_type = "FARGATE"
  
  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id] 
    security_groups  = [aws_security_group.ecs_security_group.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.poc_revamp_ecs_containers.arn
    container_name   = "hashicorp-http-echo-container"
    container_port   = var.container_port
  }
}



// CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_cluster" {
  name = "ecs_cluster"
}


 #Create CloudWatch Log Group for ECS container logs
# resource "aws_cloudwatch_log_group" "ecs_logs" {
#   name = "/ecs/your-ecs-cluster" # Adjust the log group name as per your requirements
#   retention_in_days = 7 # Adjust retention period as needed
# }

# Create CloudWatch metric alarm for CPU utilization
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_alarm" {
  alarm_name          = "ecs-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300 # 5-minute period
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU utilization exceeds 70%"
  alarm_actions       = [aws_sns_topic.notification_topic.arn]
  
  dimensions = {
    ClusterName = aws_ecs_cluster.poc_assessment.id
  }
}

# Create SNS topic for notifications
resource "aws_sns_topic" "notification_topic" {
  name = "ecs-cpu-usage-alert"
}

# Subscribe your email to the SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol  = "email"
  endpoint  = "Josephifekwe97@gmail.com" 
}