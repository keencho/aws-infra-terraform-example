resource "aws_route53_zone" "keencho" {
  name = "keencho.com"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "app-keencho-route53"
  }
}

resource "aws_route53_record" "app-admin-test" {
  zone_id = aws_route53_zone.keencho.id
  name    = "app-admin-test.keencho.com"
  type    = "A"

  alias {
    name                   = aws_lb.app-alb.dns_name
    zone_id                = aws_lb.app-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app-user-test" {
  zone_id = aws_route53_zone.keencho.id
  name    = "app-user-test.keencho.com"
  type    = "A"

  alias {
    name                   = aws_lb.app-alb.dns_name
    zone_id                = aws_lb.app-alb.zone_id
    evaluate_target_health = true
  }
}