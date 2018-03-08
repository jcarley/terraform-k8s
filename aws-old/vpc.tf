# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

# resource "aws_vpc_dhcp_options" "ec2_internal" {
#   domain_name_servers  = ["AmazonProvidedDNS"]
#
#   tags {
#     Name = "terraform_example"
#   }
# }
#
# resource "aws_vpc_dhcp_options_association" "ec2_internal" {
#   vpc_id = "${aws_vpc.default.id}"
#   dhcp_options_id = "${aws_vpc_dhcp_options.ec2_internal.id}"
# }

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  # availability_zone       = "${var.aws_availability_zone}"
  map_public_ip_on_launch = true
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}



