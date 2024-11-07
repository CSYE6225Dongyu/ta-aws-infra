output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

# output "public_ip" {
#   value       = aws_instance.application.public_ip
#   description = "Public IP address of the EC2 instance"
# }

output "db_port" {
  value       = aws_db_instance.rds_instance.endpoint
  description = "Private hosturlfor RDS"
}

# output S3 crendential in local
output "s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}