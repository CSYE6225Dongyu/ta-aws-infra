resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "application-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# use auto scalling
# resource "aws_instance" "application" {
#   ami                         = data.aws_ami.latest_ami.id
#   instance_type               = var.instance_type
#   subnet_id                   = aws_subnet.public[0].id
#   vpc_security_group_ids      = [aws_security_group.application_sg.id]
#   associate_public_ip_address = truec

#   # attach IAM role to ec2
#   iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

#   key_name = var.key_pair_name

#   root_block_device {
#     volume_size           = 25
#     volume_type           = "gp2"
#     delete_on_termination = true
#   }
#   user_data = <<-EOF
#               #!/bin/bash
#               sudo mkdir -p /etc/webapp
#               echo "DB_URL=jdbc:mysql://${aws_db_instance.rds_instance.endpoint}/csye6225" | sudo tee -a /etc/webapp/.env
#               echo "DB_USERNAME=${var.db_username}" | sudo tee -a /etc/webapp/.env
#               echo "DB_PASSWORD=${var.db_password}" | sudo tee -a /etc/webapp/.env
#               echo "AWS_S3_BUCKET_NAME"=${aws_s3_bucket.my_bucket.bucket} | sudo tee -a /etc/webapp/.env
#               echo "AWS_REGION=${var.aws_region}" | sudo tee -a /etc/webapp/.env
#               EOF

#   tags = {
#     Name = "application-instance"
#   }
#   depends_on = [aws_db_instance.rds_instance]
# }


# # rds instance
# resource "aws_db_instance" "rds_instance" {
#   identifier        = "csye6225"
#   engine            = "mysql"
#   instance_class    = "db.t3.micro"
#   allocated_storage = 20

#   db_name  = "csye6225"
#   username = var.db_username
#   password = var.db_password

#   db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
#   parameter_group_name   = aws_db_parameter_group.csye6225_mysql.name
#   vpc_security_group_ids = [aws_security_group.database_sg.id]

#   publicly_accessible = false
#   multi_az            = false
#   skip_final_snapshot = true
# }


# UUID as S3 bucket name
resource "random_uuid" "bucket_name" {}

# create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket        = random_uuid.bucket_name.result
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket_encryption" {
  bucket = aws_s3_bucket.my_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" 
    }
  }
}

# user aws_s3_bucket_lifecycle_configuration to set life
resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.bucket

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# instance template
resource "aws_launch_template" "application_launch_template" {
  name_prefix   = "csye6225_asg"
  image_id      = data.aws_ami.latest_ami.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application_sg.id]
    # automatically set by ASG
    # subnet_id                   = aws_subnet.public[0].id 
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo mkdir -p /etc/webapp
              echo "DB_URL=jdbc:mysql://${aws_db_instance.rds_instance.endpoint}/csye6225" | sudo tee -a /etc/webapp/.env
              echo "DB_USERNAME=${var.db_username}" | sudo tee -a /etc/webapp/.env
              echo "DB_PASSWORD=${var.db_password}" | sudo tee -a /etc/webapp/.env
              echo "AWS_S3_BUCKET_NAME=${aws_s3_bucket.my_bucket.bucket}" | sudo tee -a /etc/webapp/.env
              echo "AWS_REGION=${var.aws_region}" | sudo tee -a /etc/webapp/.env
              EOF

  tags = {
    Name = "application-instance-template"
  }
}
