provider "aws" {
  region = "us-east-1"
  profile = "secret_kafka_queue"
}

resource "aws_iam_role_policy" "ecs_service_policy" {
    name = "ecs_service_policy"
    role = "${aws_iam_role.ecs_service_role.id}"
    policy = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_service_role" {
    name = "ecs_service_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_policy" {
    name = "ec2_policy"
    role = "${aws_iam_role.ec2_role.id}"
    policy = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:RegisterContainerInstance",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Submit*",
        "ecs:Poll"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ec2_role" {
    name = "ec2_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": [
        "sts:AssumeRole"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs_profile" {
    name = "ecs_profile"
    roles = ["${aws_iam_role.ec2_role.name}"]
}

resource "aws_security_group" "ecs_load_balancer" {
  name = "ecs_load_balancer"
  vpc_id = "${var.vpc.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.ecs_node.id}"]
  }
}

resource "aws_security_group" "ecs_node" {
  name = "ecs_node"
  vpc_id = "${var.vpc.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port = 22
  #   to_port = 22
  #   protocol = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # egress {
  #   from_port = 443
  #   to_port = 443
  #   protocol = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port = 1024
  #   to_port = 65535
  #   protocol = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port = 0
  #   to_port = 0
  #   protocol = "-1"
  #   cidr_blocks = ["10.4.0.0/16"]
  # }
}

resource "template_file" "user_data" {
  template = "${file("userdata.sh.tpl")}"

  vars {
    CLUSTER_NAME = "${var.cluster_name}"
  }
}

resource "aws_launch_configuration" "ecs_lc" {
  name_prefix = "ecs_launch_configuration-"
  image_id = "${var.image_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.ecs_node.id}"]
  associate_public_ip_address = true
  user_data = "${template_file.user_data.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_profile.id}"
  enable_monitoring = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_cluster" "nonprod" {
  name = "${var.cluster_name}"
}

resource "aws_autoscaling_group" "ecs_cluster_asg" {
  # availability_zones = [ "us-east-1a", "us-east-1a" ,"us-east-1a" ]
  vpc_zone_identifier = [
      "${var.subnets.pub0}",
      "${var.subnets.pub1}",
      "${var.subnets.pub2}"
  ]
  name = "ecs-cluster-asg"
  max_size = 5
  min_size = 1

  force_delete = false
  desired_capacity = 1

  launch_configuration = "${aws_launch_configuration.ecs_lc.name}"

  tag {
      key = "Name"
      value = "ecs-cluster-asg"
      propagate_at_launch = true
  }

  tag {
      key = "ClusterName"
      value = "nonprod"
      propagate_at_launch = true
  }


  lifecycle {
    create_before_destroy = true
  }
}