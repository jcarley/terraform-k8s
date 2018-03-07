resource "aws_security_group" "console" {
  vpc_id = "${aws_vpc.default.id}"

  tags = "${merge(map(
      "Name", "${var.cluster_name}_console_sg",
      "kubernetes.io/cluster/${var.cluster_name}", "owned"
    ), var.extra_tags)}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }
}
