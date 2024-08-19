resource "aws_acm_certificate" "ssl-certificate" {
  domain_name       = "*.keencho.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "ssl-certificate-virginia" {
  domain_name       = "*.keencho.com"
  validation_method = "DNS"
  provider = aws.us-east-1

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "ssl-certificate-validation" {
  certificate_arn         = aws_acm_certificate.ssl-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.app-certificate-validation : record.fqdn]
}