# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = "${merge(map(
      "Name", "${var.cluster_name}.${var.base_domain}",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
      "KubernetesCluster", "${var.cluster_name}",
    ), var.extra_tags)}"
}

resource "aws_vpc_dhcp_options" "internal_domain" {
  domain_name         = "${var.aws_region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster = "${var.cluster_name}"
    Name              = "${var.cluster_name}"
  }
}

resource "aws_vpc_dhcp_options_association" "internal_domain" {
  vpc_id          = "${aws_vpc.default.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.internal_domain.id}"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    KubernetesCluster = "${var.cluster_name}"
    Name              = "${var.cluster_name}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "${var.private_subnet_cidr_block}"
  availability_zone = "${var.aws_availability_zone}"

  tags = "${merge(map(
      "Name", "Private subnet",
      "Network", "Private",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
      "KubernetesCluster", "${var.cluster_name}",
      "kubernetes.io/role/elb", "1",
    ), var.extra_tags)}"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_subnet_cidr_block}"
  availability_zone       = "${var.aws_availability_zone}"
  map_public_ip_on_launch = true

  tags = "${merge(map(
      "Name", "Public subnet",
      "Network", "Public",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
      "KubernetesCluster", "${var.cluster_name}",
      "kubernetes.io/role/elb", "1",
    ), var.extra_tags)}"
}

# The NAT IP for the private subnet, as seen from within the public one
resource "aws_eip" "nat_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.internet_gateway"]
}

# The NAT gateway for the private subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"

  depends_on = ["aws_internet_gateway.internet_gateway"]
}

# Private routing
resource "aws_route_table" "private_routes" {
  vpc_id = "${aws_vpc.default.id}"

  tags = "${merge(map(
      "Name", "Private subnets",
      "Network", "Private",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
    ), var.extra_tags)}"
}

resource "aws_route" "private_subnet_route" {
  route_table_id         = "${aws_route_table.private_routes.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_gateway.id}"
  depends_on             = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_route_table_association" "private_subnet_route_table_assoc" {
  route_table_id = "${aws_route_table.private_routes.id}"
  subnet_id      = "${aws_subnet.private_subnet.id}"
}

# Public routing
resource "aws_route_table" "public_routes" {
  vpc_id = "${aws_vpc.default.id}"

  tags = "${merge(map(
      "Name", "Public subnets",
      "Network", "Public",
      "kubernetes.io/cluster/${var.cluster_name}", "owned",
    ), var.extra_tags)}"
}

resource "aws_route" "public_subnet_route" {
  route_table_id         = "${aws_route_table.public_routes.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_gateway.id}"
  depends_on             = ["aws_internet_gateway.internet_gateway"]
}

resource "aws_route_table_association" "public_subnet_route_table_assoc" {
  route_table_id = "${aws_route_table.public_routes.id}"
  subnet_id      = "${aws_subnet.public_subnet.id}"
}

