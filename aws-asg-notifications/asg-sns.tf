resource "aws_launch_configuration" "test_lc" {
    name = "cluster_config"
    image_id = "ami-8fcee4e5"
    instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "test-asg" {
    # availability_zones = [ "us-east-1a", "us-east-1a" ,"us-east-1a" ]
    vpc_zone_identifier = [
        "${aws_subnet.pub.0.id}",
        "${aws_subnet.pub.1.id}",
        "${aws_subnet.pub.2.id}",
    ]
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

# resource  "aws_iam_role" "test-asg" {
#     name = "test_role"
#     assume_role_policy = <<EOF
#     {
#       "Version": "2012-10-17",
#       "Statement": [
#         {
#           "Action": "sns:Publish",
#           "Principal": {
#             "Service": "ec2.amazonaws.com"
#           },
#           "Effect": "Allow",
#           "Sid": ""
#         }
#       ]
#     }
#     EOF

# }

# resource "aws_autoscaling_lifecycle_hook" "test-asg" {
#     name = "test-hook"
#     autoscaling_group_name = "${aws_autoscaling_group.test-asg.name}"
#     default_result = "CONTINUE"
#     heartbeat_timeout = 2000
#     lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
#     notification_metadata = <<EOF
#     {
#         "free": "food"
#     }
#     EOF
#         notification_target_arn = ""
# }