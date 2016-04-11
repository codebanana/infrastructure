resource "aws_network_acl" "vpc" {
	vpc_id = "${aws_vpc.vpc.id}"
	subnet_ids = ["${aws_subnet.pub.*.id}"]

	tags {
		Name = "nonprod-acl"
	}
}

resource "aws_network_acl_rule" "egress100"{
	network_acl_id = "${aws_network_acl.vpc.id}"
	rule_number = 100
	egress = true
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
	from_port = 80
	to_port = 80
}

resource "aws_network_acl_rule" "egress101"{
	network_acl_id = "${aws_network_acl.vpc.id}"
	rule_number = 101
	egress = true
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
	from_port = 443
	to_port = 443
}

resource "aws_network_acl_rule" "egress102"{
	network_acl_id = "${aws_network_acl.vpc.id}"
	rule_number = 102
	egress = true
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
	from_port = 1024
	to_port = 65535
}

resource "aws_network_acl_rule" "ingress100"{
	network_acl_id = "${aws_network_acl.vpc.id}"
	rule_number = 100
	egress = false
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
	from_port = 80
	to_port = 80
}

resource "aws_network_acl_rule" "ingress101"{
	network_acl_id = "${aws_network_acl.vpc.id}"
	rule_number = 101
	egress = false
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
	from_port = 443
	to_port = 443
}

resource "aws_network_acl_rule" "ingress102"{
	network_acl_id = "${aws_network_acl.vpc.id}"
	rule_number = 102
	egress = false
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
	from_port = 22
	to_port = 22
}

resource "aws_network_acl_rule" "ingress200"{
	network_acl_id = "${aws_network_acl.vpc.id}"
	rule_number = 200
	egress = false
	protocol = "tcp"
	rule_action = "allow"
	cidr_block = "0.0.0.0/0"
	from_port = 1024
	to_port = 65535
}