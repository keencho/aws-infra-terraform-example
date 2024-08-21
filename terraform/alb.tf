########## alb
resource "aws_lb" "app-alb" {
  name = "app-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.app-alb-sg.id]
  subnets = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false
}

resource "aws_security_group" "app-alb-sg" {
  name        = "app-alb-sg"
  description = "security group for application load balancer"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-alb-sg"
  }
}

resource "aws_lb_target_group" "app-test" {
  name = "app-test"

  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.vpc.id

  health_check {
    path = var.alb-health-check-path
    port = "traffic-port"
  }
}

resource "aws_lb_listener" "app-alb-listener-http" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "app-alb-listener-https" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = aws_acm_certificate.ssl-certificate.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app-test.arn
  }
}

resource "aws_lb_target_group_attachment" "app-test-attachment" {
  target_group_arn = aws_lb_target_group.app-test.id
  target_id        = aws_instance.app-test-ec2.id
  port             = 80
}

resource "aws_lb_listener_rule" "app-alb-test-rule" {
  listener_arn = aws_lb_listener.app-alb-listener-https.arn
  priority = 1

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app-test.arn
  }

  condition {
    host_header {
      values = ["app-admin-test.keencho.com", "app-user-test.keencho.com"]
    }
  }
}