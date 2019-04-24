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
