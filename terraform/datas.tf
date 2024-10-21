
# latest AMI id
data "aws_ami" "latest_ami" {
  most_recent = true
  owners      = [var.account_id]

  filter {
    name   = "name"
    values = ["csye6225-webapp-image-*"]
  }
}