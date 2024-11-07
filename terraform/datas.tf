
# latest AMI id
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