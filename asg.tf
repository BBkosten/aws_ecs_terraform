resource "aws_autoscaling_group" "production-asg" {
  name                  = "${var.ecs_cluster_name}-ecs-autoscaling-group"
  max_size              = var.autoscale_max
  min_size              = var.autoscale_min
  desired_capacity      = var.autoscale_desired
  vpc_zone_identifier   = aws_subnet.private.*.id
  launch_configuration  = aws_launch_configuration.ecs-lc.name
  health_check_type     = "ELB"

  tag {
    key                 = "Name"
    value               = "ECS-Instance-${var.ecs_cluster_name}-service"
    propagate_at_launch = true
  }
}
