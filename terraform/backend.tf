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

############################################################################# efs

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
  count = "${length(aws_subnet.private.*.id)}"
  file_system_id  = "${aws_efs_file_system.app-efs.id}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  security_groups = ["${aws_security_group.app-efs-sg.id}"]
}

############################################################################# ecs

resource "aws_ecr_repository" "app-ecr" {
  name                 = "app-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_iam_role" "app-ecs-task-execution-role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app-ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.app-ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "nginx-container-name" {
  default = "nginx"
}

resource "aws_ecs_task_definition" "app-definition" {
  family = "app-definition"
  requires_compatibilities = ["FARGATE"]
  cpu = 1024
  memory = "2048"
  network_mode = "awsvpc"

  task_role_arn = aws_iam_role.app-ecs-task-execution-role.arn
  execution_role_arn = aws_iam_role.app-ecs-task-execution-role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = var.nginx-container-name
      image     = "${aws_ecr_repository.app-ecr.repository_url}:nginx-latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],
      healthCheck = {
        command = ["CMD-SHELL", "curl -f http://localhost:80/health-check || exit 1"]
      }
    },
    {
      name      = "admin"
      image     = "${aws_ecr_repository.app-ecr.repository_url}:admin-latest"
      essential = true
      portMappings = [
        {
          containerPort = 10000
          hostPort      = 10000
        }
      ],
      environment = [
        {
          name  = "spring.profiles.active",
          value = "prod"
        },
        {
          "name": "logging.file.name",
          "value": "/app-efs/logs/prod/admin/$(curl -s $ECS_CONTAINER_METADATA_URI_V4/task | jq -r .TaskARN | cut -d '/' -f 3).log"
        },
        {
          "name": "server.port",
          "value": "10000"
        },
        {
          "name": "db_url",
          "value": "jdbc:postgresql://${aws_db_instance.app-rds.endpoint}/${aws_db_instance.app-rds.db_name}"
        },
        {
          "name": "db_username",
          "value": var.db-username
        },
        {
          "name": "db_password",
          "value": var.db-password
        },
      ],
      mountPoints: [
        {
          sourceVolume: "app-efs",
          containerPath: "/app-efs",
          readOnly: false
        }
      ],
      healthCheck = {
        command = ["CMD-SHELL", "curl -f http://localhost:10000/api/health-check || exit 1"]
      }
    },
    {
      name      = "user"
      image     = "${aws_ecr_repository.app-ecr.repository_url}:user-latest"
      essential = true
      portMappings = [
        {
          containerPort = 10010
          hostPort      = 10010
        }
      ],
      environment = [
        {
          name  = "spring.profiles.active",
          value = "prod"
        },
        {
          "name": "logging.file.name",
          "value": "/app-efs/logs/prod/user/$(curl -s $ECS_CONTAINER_METADATA_URI_V4/task | jq -r .TaskARN | cut -d '/' -f 3).log"
        },
        {
          "name": "server.port",
          "value": "10010"
        },
        {
          "name": "db_url",
          "value": "jdbc:postgresql://${aws_db_instance.app-rds.endpoint}/${aws_db_instance.app-rds.db_name}"
        },
        {
          "name": "db_username",
          "value": var.db-username
        },
        {
          "name": "db_password",
          "value": var.db-password
        },
      ],
      mountPoints: [
        {
          sourceVolume: "app-efs",
          containerPath: "/app-efs",
          readOnly: false
        }
      ],
      healthCheck = {
        command = ["CMD-SHELL", "curl -f http://localhost:10010/api/health-check || exit 1"]
      }
    }
  ])

  volume {
    name = "app-efs"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.app-efs.id
      root_directory = "/"
    }
  }

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_ecs_cluster" "app-cluster" {
  name = "app-cluster"
}

resource "aws_security_group" "app-ecs-service-sg" {

  name        = "app-ecs-service-sg"
  description = "security group for ecs service"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "alb traffic"
    from_port   = 0
    to_port     = 65535
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
    Name = "app-ecs-service-sg"
  }
}

resource "aws_lb_target_group" "app-ecs-service-tg1" {
  name = "app-ecs-service-tg1"

  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.vpc.id

  health_check {
    path = var.alb-health-check-path
    port = "traffic-port"
  }
}

resource "aws_lb_target_group" "app-ecs-service-tg2" {
  name = "app-ecs-service-tg2"

  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.vpc.id

  health_check {
    path = var.alb-health-check-path
    port = "traffic-port"
  }
}

resource "aws_lb_listener_rule" "app-alb-ecs-service-rule" {
  listener_arn = aws_lb_listener.app-alb-listener-https.arn
  priority = 2

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app-ecs-service-tg1.arn
  }

  condition {
    host_header {
      values = ["app-admin.keencho.com", "app-user.keencho.com"]
    }
  }
}

resource "aws_ecs_service" "app-ecs-service" {
  name = "app-ecs-service"
  cluster = aws_ecs_cluster.app-cluster.id
  task_definition = aws_ecs_task_definition.app-definition.arn
  desired_count = 1
  launch_type = "FARGATE"
  propagate_tags = "SERVICE"
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets = aws_subnet.private[*].id
    security_groups = [aws_security_group.app-ecs-service-sg.id]
    assign_public_ip = false
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app-ecs-service-tg1.arn
    container_name = var.nginx-container-name
    container_port = 80
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

############################################################################# auto scailing

resource "aws_iam_role" "app-ecs-autoscale" {
  name = "app-ecs-autoscale-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "Autoscaling"
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app-ecs-autoscale" {
  role = aws_iam_role.app-ecs-autoscale.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

resource "aws_appautoscaling_target" "app-ecs-target" {
  min_capacity = 1
  max_capacity = 4
  resource_id = "service/${aws_ecs_cluster.app-cluster.name}/${aws_ecs_service.app-ecs-service.name}"
  role_arn = aws_iam_role.app-ecs-task-execution-role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"

  depends_on = [
    aws_ecs_service.app-ecs-service
  ]
}

resource "aws_appautoscaling_policy" "app-ecs-policy-scale-out" {
  name = "scale-out"
  policy_type = "StepScaling"
  resource_id = aws_appautoscaling_target.app-ecs-target.resource_id
  scalable_dimension = aws_appautoscaling_target.app-ecs-target.scalable_dimension
  service_namespace = aws_appautoscaling_target.app-ecs-target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type = "PercentChangeInCapacity"
    cooldown = 1
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = 100
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "app-ecs-cpu-high" {
  alarm_name          = "app-ecs-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    ClusterName = aws_ecs_cluster.app-cluster.name
    ServiceName = aws_ecs_service.app-ecs-service.name
  }

  alarm_actions = [aws_appautoscaling_policy.app-ecs-policy-scale-out.arn]
}