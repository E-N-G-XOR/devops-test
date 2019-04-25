locals {
  prefix = "ecs-cluster-${var.name}"
}

data "template_file" "bootstrap" {
  template = "${file("${path.module}/templates/bootstrap.tpl")}"

  vars {
    CLUSTER_NAME = "${var.name}"
  }
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux/recommended/image_id"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}"
}

resource "aws_iam_instance_profile" "ecs_host" {
  name = "ecs-host-${var.name}"
  path = "/"
  role = "${aws_iam_role.ecs_host.id}"
}

resource "aws_launch_template" "ecs_host" {
  name_prefix   = "${local.prefix}-launch-configuration"
  image_id      = "${data.aws_ssm_parameter.ami.value}"
  instance_type = "${var.instance_type}"

  iam_instance_profile {
    name = "${aws_iam_instance_profile.ecs_host.name}"
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true

    security_groups = [
      "${aws_security_group.role_ecs_host.id}",
    ]
  }

  user_data = "${base64encode(data.template_file.bootstrap.rendered)}"

  block_device_mappings {
    device_name = "/dev/xvdcz"

    ebs {
      volume_type = "standard"
      volume_size = "30"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags {
      Name = "ecs-host-${var.name}"
    }
  }
}

resource "aws_autoscaling_group" "autoscaling" {
  name              = "${local.prefix}-autoscaling"
  min_size          = "1"
  max_size          = "3"
  desired_capacity  = "1"
  health_check_type = "EC2"

  launch_template {
    id      = "${aws_launch_template.ecs_host.id}"
    version = "$Latest"
  }

  vpc_zone_identifier = [
    "${var.subnets}",
  ]
}
