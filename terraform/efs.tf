############################################################################ efs

resource "aws_security_group" "app-efs-sg" {
  name        = "app-efs-sg"
  description = "security group for ecs service"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow 2049"
    from_port   = 2049
    to_port     = 2049
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
    Name = "app-efs-sg"
  }
}

resource "aws_efs_file_system" "app-efs" {
  encrypted = true
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_90_DAYS"
  }
}

resource "aws_efs_mount_target" "app-efs-target" {
  count          = "${length(aws_subnet.private.*.id)}"
  file_system_id = "${aws_efs_file_system.app-efs.id}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  security_groups = ["${aws_security_group.app-efs-sg.id}"]
}