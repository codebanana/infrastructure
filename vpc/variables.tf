variable "vpc_names" {
	default = {
		nonprod = "nonprod"
	}
}

variable "availability_zones" {
	default = {
		zone0 = "us-east-1b"
		zone1 = "us-east-1c"
		zone2 = "us-east-1d"
	}
}

variable "cidr_blocks" {
	default = {
		zone0 = "10.4.0.0/24"
		zone1 = "10.4.1.0/24"
		zone2 = "10.4.2.0/24"
	}
}