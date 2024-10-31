data "aws_route53_zone" "selected_zone" {
  name = "${var.sub_domain}.${var.top_level_domain}"
}

# A record 
resource "aws_route53_record" "app_a_record" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "${var.sub_domain}.${var.top_level_domain}"
  type    = "A"
  ttl     = 60

  records = [aws_instance.application.public_ip]
}