resource "aws_ecr_repository" "repo" {
  name = "lw-repo-${var.name}"
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = "${aws_ecr_repository.repo.name}"
  policy     = "${file("${path.module}/templates/lifecycle-policy.json")}"
}

locals {
  // Port range from https://aws.amazon.com/premiumsupport/knowledge-center/troubleshoot-unhealthy-checks-ecs
  tasks_port_range = {
    from = 32768
    to   = 65535
  }
}

resource "aws_iam_role" "ecs_host" {
  name = "${var.name}-ecs-host"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com",
          "ecs.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = "${aws_iam_role.ecs_host.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = "${aws_iam_role.ecs_host.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_security_group" "role_ecs_host" {
  name        = "${var.name}-role-ecs-host"
  description = "ECS default security group"
  vpc_id      = "${var.vpc_id}"

  // Allow traffic from VPC to ECS tasks
  ingress {
    from_port   = "${local.tasks_port_range["from"]}"
    to_port     = "${local.tasks_port_range["to"]}"
    protocol    = "TCP"
    cidr_blocks = ["${data.aws_vpc.selected.cidr_block}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

// Normally when you create the a schedule task from the interface
// AWS automatically creates a role called ecsEventsRole that can
// run the task, so this replicates that functionality
// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/CWE_IAM_role.html
resource "aws_iam_role" "event_role" {
  name = "${var.name}-ecsEventsRole"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "events.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "event_policy" {
  role       = "${aws_iam_role.event_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}


locals {
  prefix = "ecs-cluster-${var.name}"
}

data "template_file" "bootstrap" {
  template = "${file("${path.module}/templates/bootstrap.tpl")}"

  vars = {
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

    tags = {
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

  vpc_zone_identifier = "${var.subnets}"

  }
