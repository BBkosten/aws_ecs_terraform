resource "aws_lb" "production-lb" {
  name               = "${var.ecs_cluster_name}-service-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public.*.id

  tags = {
    Name = "${var.ecs_cluster_name}-service-alb"
  }
}

resource "aws_lb_target_group" "production-tg" {
  name        = "${var.ecs_cluster_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.Production_vpc.id
  target_type = "instance"

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "listener-for-lb" {
  load_balancer_arn  = aws_lb.production-lb.arn
  port               = "80"
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.production-tg.arn
  }
}
