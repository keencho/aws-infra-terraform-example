############################################################################# rds
resource "aws_security_group" "app-rds-sg" {

  name        = "app-rds-sg"
  description = "security group for rds"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "postgresSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-rds-sg"
  }
}

resource "aws_db_subnet_group" "app-rds-subnet-group" {
  name  = "app-rds-subnet-group"
  subnet_ids = aws_subnet.public[*].id

  tags = {
    name = "app-rds-subnet-group"
  }
}

variable "db-username" {
  type = string
  default = "postgres"
}

variable "db-password" {
  type = string
  default = "postgres2024"
}

resource "aws_db_instance" "app-rds" {
  db_name              = "app"
  identifier           = "app-rds"
  engine               = "postgres"
  engine_version       = "15.8"
  storage_type         = "gp2"
  allocated_storage    = 20
  instance_class       = "db.t3.micro"
  username             = var.db-username
  password             = var.db-password
  parameter_group_name = "default.postgres15"
  skip_final_snapshot  = true
  publicly_accessible  = true

  vpc_security_group_ids = [aws_security_group.app-rds-sg.id]
  db_subnet_group_name = aws_db_subnet_group.app-rds-subnet-group.name
}