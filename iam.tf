#*********************** instance *******************
resource "aws_iam_role" "ecs-instance-role" {
  name = "${var.ecs_cluster_name}-ecs-instance-role"
  path = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs-instance-policy.json
}

data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions       = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "${var.ecs_cluster_name}-ecs-instance-profile"
  path = "/"
  role = aws_iam_role.ecs-instance-role.id
}

#*********************** ECS *******************
data "aws_iam_policy_document" "assume_by_ecs" {
  statement {
    sid           = "AllowAssumeByEcsTasks"
    effect        = "Allow"
    actions       = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "execution_role" {
  statement {
    sid         = "AllowECRLogging"
    effect      = "Allow"

    actions     = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources   = ["*"]
  }
}

data "aws_iam_policy_document" "task_role" {
  statement {
    sid              = "AllowDescribeCluster"
    effect           = "Allow"
    actions          = ["ecs:DescribeClusters"]
    resources        = [aws_ecs_cluster.production.arn]
  }
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.ecs_cluster_name}_ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy" "execution_role" {
  role               = aws_iam_role.execution_role.name
  policy             = data.aws_iam_policy_document.execution_role.json
}

resource "aws_iam_role" "task_role" {
  name               = "${var.ecs_cluster_name}_ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy" "task_role" {
  role               = aws_iam_role.task_role.name
  policy             = data.aws_iam_policy_document.task_role.json
}
