resource "aws_ecs_cluster" "production" {
  name = "${var.ecs_cluster_name}-cluster"
}

resource "aws_ecs_task_definition" "My_task" {
  family                            = var.ecs_cluster_name
  execution_role_arn                = aws_iam_role.execution_role.arn
  task_role_arn                     = aws_iam_role.task_role.arn
  network_mode                      = "bridge"
  requires_compatibilities          = ["EC2"]
  container_definitions             = file("container-definitions/container-definitions.json")
}


resource "aws_ecs_service" "My_app_service" {
  name                               = "${var.ecs_cluster_name}-service"
  task_definition                    = aws_ecs_task_definition.My_task.id
  cluster                            = aws_ecs_cluster.production.arn

  load_balancer {
    target_group_arn                 = aws_lb_target_group.production-tg.arn
    container_name                   = "hylobatesapp"
    container_port                   = 80
  }

  launch_type                        = "EC2"
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  depends_on = [aws_lb_listener.listener-for-lb]
}



