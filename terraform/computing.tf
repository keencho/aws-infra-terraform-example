########## alb
resource "aws_lb" "app-alb" {
  name = "app-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.app-alb-sg.id]
  subnets = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true
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

resource "aws_lb_listener" "app-alb-listener" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-test.arn
  }
}

resource "aws_lb_target_group_attachment" "app-test-attachment" {
  target_group_arn = aws_lb_target_group.app-test.id
  target_id        = aws_instance.app-test-ec2.id
  port             = 80
}

resource "aws_lb_listener_rule" "app-alb-test-rule" {
  listener_arn = aws_lb_listener.app-alb-listener.arn
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

########## ec2
resource "aws_instance" "app-test-ec2" {
  ami = "ami-0b8414ae0d8d8b4cc"
  instance_type = "t2.micro"
  availability_zone = "${var.aws_region}${element(var.availability_zones, 0)}"
  subnet_id = aws_subnet.public[0].id
  key_name = aws_key_pair.app-test-key-pair.key_name

  vpc_security_group_ids = [aws_security_group.app-test-sg.id]

  tags = {
    Name = "app-test-ec2"
  }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "app-test-key-pair" {
  key_name   = "app-test-key-pair"
  public_key = tls_private_key.pk.public_key_openssh
}

output "private_key" {
  value     = tls_private_key.pk.private_key_pem
  sensitive = true
}

resource "aws_security_group" "app-test-sg" {
  name        = "app-test-sg"
  description = "security group for app test instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "postgresSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.app-alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-test-sg"
  }
}

resource "aws_eip" "app-test-ec2-eip" {
  instance = "${aws_instance.app-test-ec2.id}"
  vpc   = true

  tags = {
    Name = "app-test-eip"
  }
}