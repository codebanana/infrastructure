variable "vpc" {
	type = "map"
	default = {}
}

variable "subnets" {
	type = "map"
	default = {}
}

variable "security_groups" {
	type = "map"
	default = {}
}

variable "image_id" {
	type = "string"
	default = "ami-33b48a59"
	description = "amzn-ami-2015.09.g-amazon-ecs-optimized"
}

variable "ssh_key_name" {
	type = "string"
	default = "nonprod"
}

variable "instance_type" {
	type = "string"
	default = "t2.medium"
}

variable "cluster_name" {
	type = "string"
	default = "test-cluster"
}