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