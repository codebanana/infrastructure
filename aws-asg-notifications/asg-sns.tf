provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "test_lc" {
  name = "cluster_config"
  image_id = "ami-8fcee4e5"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "test-asg" {
  vpc_zone_identifier = ["${split(",","var.subnet_ids")}"]
  name = "test-asg"
  max_size = 5
  min_size = 3

  force_delete = false
  desired_capacity = 3

  launch_configuration = "${aws_launch_configuration.test_lc.name}"

  tag {
      key = "Name"
      value = "test-asg"
      propagate_at_launch = true
  }

  tag {
      key = "ClusterName"
      value = "test-asg"
      propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_sns_topic" "test-asg" {
  name = "test-asg"
}

resource "aws_sqs_queue" "test-asg" {
  name = "test-asg"
}

resource "aws_sns_topic_subscription" "test-asg" {
  topic_arn = "${aws_sns_topic.test-asg.arn}"
  protocol = "sqs"
  endpoint = "${aws_sqs_queue.test-asg.arn}"
}

resource "aws_autoscaling_notification" "test-asg" {
  group_names = ["${aws_autoscaling_group.test-asg.name}"]
  notifications = [
      "autoscaling:EC2_INSTANCE_LAUNCH",
      "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
      "autoscaling:EC2_INSTANCE_TERMINATE",
      "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = "${aws_sns_topic.test-asg.arn}"
}
