# variable "revamp_elb_name" {
#   type =  string
#   default = "load-balance"
# }


# variable "revamp_frontend_target_group" {
#     type = string
#     default = "load-balancer-target_group"
  
# }





# variable "revamp_frontend_target_group1" {
#     type = string
#     default = "test"
  
# }


variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "aws_region" {
  description = "AWS Region"
}

variable "vpc_cidr" {
  description = "CIDR Block for VPC"
}

variable "vpc_name" {
  description = "Name for VPC"
}

variable "public_subnet_1_cidr" {
  description = "CIDR Block for Public Subnet 1"
}

variable "public_subnet_1_az" {
  description = "Availability Zone for Public Subnet 1"
}

variable "public_subnet_2_cidr" {
  description = "CIDR Block for Public Subnet 2"
}

variable "public_subnet_2_az" {
  description = "Availability Zone for Public Subnet 2"
}

variable "private_subnet_1_cidr" {
  description = "CIDR Block for Private Subnet 1"
}

variable "private_subnet_1_az" {
  description = "Availability Zone for Private Subnet 1"
}

variable "private_subnet_2_cidr" {
  description = "CIDR Block for Private Subnet 2"
}

variable "private_subnet_2_az" {
  description = "Availability Zone for Private Subnet 2"
}

variable "revamp_elb_name" {
  description = "Name for ELB"
}

variable "container_port" {
  
}

variable "task_execution_role" {
  
}


// Define other variables as needed...
