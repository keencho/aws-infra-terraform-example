resource "aws_route53_zone" "keencho" {
  name = "keencho.com"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "app-keencho-route53"
  }
}

resource "aws_route53_record" "app-certificate-validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl-certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.keencho.id
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

resource "aws_route53_record" "app-admin" {
  zone_id = aws_route53_zone.keencho.id
  name    = "app-admin.keencho.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.admin-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.admin-distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app-user" {
  zone_id = aws_route53_zone.keencho.id
  name    = "app-user.keencho.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.user-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.user-distribution.hosted_zone_id
    evaluate_target_health = true
  }
}