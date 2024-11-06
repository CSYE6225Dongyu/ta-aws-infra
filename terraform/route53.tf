
# A record 
resource "aws_route53_record" "app_alias_record" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "${var.sub_domain}.${var.top_level_domain}"
  type    = "A"

  alias {
    name                   = aws_lb.app_load_balancer.dns_name # dns for alb, dynamic ip
    zone_id                = aws_lb.app_load_balancer.zone_id
    evaluate_target_health = true
  }
}