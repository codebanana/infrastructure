output "vpc_id" {
	value = "${aws_vpc.vpc.id}"
}

output "subnet_ids" {
	value = "${join(",", aws_subnet.pub.*.id)}"
}