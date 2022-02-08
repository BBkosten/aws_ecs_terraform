resource "aws_security_group" "ecs" {
  name   = "${var.ecs_cluster_name}-allow-ecs"
  vpc_id = aws_vpc.Production_vpc.id

  /* dynamic "ingress" {
    for_each = ["80", "443", "3001", "3002", "3000", "8080"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
*/

  ingress {
    from_port       = 0
    protocol        = "-1"
    to_port         = 0
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port       = 0
    protocol        = "-1"
    to_port         = 0
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "alb" {
  name   = "${var.ecs_cluster_name}-allow-http"
  vpc_id = aws_vpc.Production_vpc.id

  ingress {
    from_port      = 80
    protocol       = "tcp"
    to_port        = 80
    cidr_blocks    = ["0.0.0.0/0"]
  }

  egress {
    from_port      = 0
    protocol       = "-1"
    to_port        = 0
    cidr_blocks    = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ecs_cluster_name}-allow-http"
  }
}