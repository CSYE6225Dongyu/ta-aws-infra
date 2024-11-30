provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# output "public_subnet_ids" {
#   description = "List of public subnet IDs"
#   value       = aws_subnet.public[*].id
# }

# output "private_subnet_ids" {
#   description = "List of private subnet IDs"
#   value       = aws_subnet.private[*].id
# }

# output "public_ip" {
#   value       = aws_instance.application.public_ip
#   description = "Public IP address of the EC2 instance"
# }

output "db_port" {
  value       = aws_db_instance.rds_instance.endpoint
  description = "Private hosturlfor RDS"
}

# # output S3 crendential in local
# output "s3_bucket_name" {
#   value = aws_s3_bucket.my_bucket.bucket
# }

output "topic_arn" {
  value       = aws_sns_topic.verification_topic.arn
  description = "SNS topic arn, used for Lambda"
}

output "launch_template_id" {
  value       = aws_launch_template.application_launch_template.id
  description = "The ID of the Launch Template, used for CI/CD"
}

output "launch_template_latest_version" {
  value       = aws_launch_template.application_launch_template.latest_version
  description = "The latest version of the Launch Template, used for CI/CD"
}

output "auto_scaling_group_name" {
  value       = aws_autoscaling_group.application_asg.name
  description = "Name of ASG, used for CI/CD"
}

# output the Key arns
output "kms_key_arns" {
  value = {
    ec2             = aws_kms_key.kms_ec2.arn
    rds             = aws_kms_key.kms_rds.arn
    s3              = aws_kms_key.kms_s3.arn
    secrets_manager = aws_kms_key.kms_secrets_manager.arn
  }
}
