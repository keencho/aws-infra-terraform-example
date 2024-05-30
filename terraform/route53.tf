resource "aws_route53_zone" "keencho" {
  name = "keencho.com"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "app-keencho-route53"
  }
}