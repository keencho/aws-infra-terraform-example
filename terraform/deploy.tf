resource "aws_codedeploy_app" "app-deploy-app" {
  compute_platform = "ECS"
  name = "app-deploy"
}

data "aws_iam_policy_document" "app-deploy-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "app-deploy-role" {
  name               = "app-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.app-deploy-assume-role.json
}

resource "aws_iam_role_policy_attachment" "app-AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.app-deploy-role.name
}

resource "aws_iam_role_policy_attachment" "app-AWSCodeDeployRoleForECS" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.app-deploy-role.name
}

resource "aws_codedeploy_deployment_group" "app-deploy-group" {
  app_name               = aws_codedeploy_app.app-deploy-app.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "app-deploy-group"
  service_role_arn       = aws_iam_role.app-deploy-role.arn

  auto_rollback_configuration {
    enabled = false
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.app-cluster.name
    service_name = aws_ecs_service.app-ecs-service2.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.app-alb-listener-https.arn]
      }

      target_group {
        name = aws_lb_target_group.app-ecs-service-tg1.name
      }

      target_group {
        name = aws_lb_target_group.app-ecs-service-tg2.name
      }
    }
  }
}