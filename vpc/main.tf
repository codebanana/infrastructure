provider "aws" {
	region = "us-east-1"
	profile = "secret_kafka_queue"
}

resource "aws_vpc" "vpc" {
	cidr_block = "10.4.0.0/16"

	tags {
		Name = "${lookup(var.vpc_names, "nonprod")}"
	}
}

resource "aws_internet_gateway" "vpc-gw" {
	vpc_id = "${aws_vpc.vpc.id}"

	tags {
		Name = "nonprod-gw"
	}
}

resource "aws_route_table" "vpc-rtb" {
	vpc_id = "${aws_vpc.vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.vpc-gw.id}"
	}

	tags {
		Name = "nonprod-route-table"
	}
}

resource "aws_main_route_table_association" "vpc-rtb-a" {
	vpc_id = "${aws_vpc.vpc.id}"
	route_table_id = "${aws_route_table.vpc-rtb.id}"
}

resource "aws_subnet" "pub" {
	vpc_id = "${aws_vpc.vpc.id}"
	availability_zone = "${lookup(var.availability_zones, concat("zone", count.index))}"
	cidr_block = "${lookup(var.cidr_blocks, concat("zone", count.index))}"
	map_public_ip_on_launch = true
	tags {
		Name = "${concat(lookup(var.vpc_names, "nonprod"), "-pub", count.index)}"
	}
	count = 3
}

resource "aws_route_table_association" "a" {
    subnet_id = "${element(aws_subnet.pub.*.id, count.index)}"
    route_table_id = "${aws_route_table.vpc-rtb.id}"
    count = 3
}