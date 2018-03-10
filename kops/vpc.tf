resource "aws_vpc" "kubernetes-example-com" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                                          = "kubernetes.example.com"
    Name                                                       = "kubernetes.example.com"
    "kubernetes.io/cluster/kubernetes.example.com" = "owned"
  }
}

resource "aws_security_group" "api-elb-kubernetes-example-com" {
  name        = "api-elb.kubernetes.example.com"
  vpc_id      = "${aws_vpc.kubernetes-example-com.id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster = "kubernetes.example.com"
    Name              = "api-elb.kubernetes.example.com"
  }
}

resource "aws_security_group" "masters-kubernetes-example-com" {
  name        = "masters.kubernetes.example.com"
  vpc_id      = "${aws_vpc.kubernetes-example-com.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "kubernetes.example.com"
    Name              = "masters.kubernetes.example.com"
  }
}

resource "aws_security_group" "nodes-kubernetes-example-com" {
  name        = "nodes.kubernetes.example.com"
  vpc_id      = "${aws_vpc.kubernetes-example-com.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster = "kubernetes.example.com"
    Name              = "nodes.kubernetes.example.com"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-example-com.id}"
  source_security_group_id = "${aws_security_group.masters-kubernetes-example-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-kubernetes-example-com.id}"
  source_security_group_id = "${aws_security_group.masters-kubernetes-example-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-kubernetes-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-example-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-kubernetes-example-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-kubernetes-example-com.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-example-com.id}"
  source_security_group_id = "${aws_security_group.api-elb-kubernetes-example-com.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-kubernetes-example-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-kubernetes-example-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-example-com.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-example-com.id}"
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-example-com.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-example-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-example-com.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-kubernetes-example-com.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-kubernetes-example-com.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "us-west-2b-kubernetes-example-com" {
  vpc_id            = "${aws_vpc.kubernetes-example-com.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "us-west-2b"

  tags = {
    KubernetesCluster                                          = "kubernetes.example.com"
    Name                                                       = "us-west-2b.kubernetes.example.com"
    "kubernetes.io/cluster/kubernetes.example.com" = "owned"
    "kubernetes.io/role/elb"                                   = "1"
  }
}

resource "aws_vpc_dhcp_options" "kubernetes-example-com" {
  domain_name         = "us-west-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster = "kubernetes.example.com"
    Name              = "kubernetes.example.com"
  }
}

resource "aws_vpc_dhcp_options_association" "kubernetes-example-com" {
  vpc_id          = "${aws_vpc.kubernetes-example-com.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.kubernetes-example-com.id}"
}

