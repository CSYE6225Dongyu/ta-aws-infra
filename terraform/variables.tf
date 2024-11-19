variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID used to fetch AMI"
}

variable "key_pair_name" {
  type = string
}

# Define rds variables
variable "db_username" {
  default = "csye6225"
}

variable "db_password" {
  default = "YourStrongPassword"
}

variable "db_name" {
  type    = string
  default = "csye6225"
}

variable "top_level_domain" {
  type    = string
  default = "csye6225dongyu.me"
}

variable "sub_domain" {
  type    = string
  default = "dev"
}

variable "SENDGRID_API_KEY" {
  type = string
}



# data: latest AMI id
data "aws_ami" "latest_ami" {
  most_recent = true
  owners      = [var.account_id]

  filter {
    name   = "name"
    values = ["csye6225-webapp-image-*"]
  }
}

data "aws_route53_zone" "selected_zone" {
  name = "${var.sub_domain}.${var.top_level_domain}"
}
