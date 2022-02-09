data "aws_availability_zones" "zones_for_APP"{}

data "aws_ami" "latest-ecs" {
  most_recent = true
  owners      = ["591542846629"] # Amazon
  #owners      = ["699717368611"]

  filter {
    name      = "name"
    values    = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }

  filter {
    name      = "virtualization-type"
    values    = ["hvm"]
  }
}


resource "aws_launch_configuration" "ecs-lc" {
  name                    = "ECS-Instance-${var.ecs_cluster_name}"
  #image_id                = "ami-05c18985688f7dffb"
  image_id                = data.aws_ami.latest-ecs.id
  instance_type           = var.instance_type
  iam_instance_profile    = aws_iam_instance_profile.ecs-instance-profile.id

  root_block_device {
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups             = [aws_security_group.ecs.id]
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.production.key_name
  user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=${var.ecs_cluster_name}-cluster >> /etc/ecs/ecs.config
                                  EOF
}
