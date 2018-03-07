resource "aws_vpc" "kubernetes-finishfirstsoftware-com" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                                          = "kubernetes.finishfirstsoftware.com"
    Name                                                       = "kubernetes.finishfirstsoftware.com"
    "kubernetes.io/cluster/kubernetes.finishfirstsoftware.com" = "owned"
  }
}

resource "aws_security_group" "api-elb-kubernetes-finishfirstsoftware-com" {
  name        = "api-elb.kubernetes.finishfirstsoftware.com"
  vpc_id      = "${aws_vpc.kubernetes-finishfirstsoftware-com.id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster = "kubernetes.finishfirstsoftware.com"
    Name              = "api-elb.kubernetes.finishfirstsoftware.com"
  }
}

resource "aws_security_group" "masters-kubernetes-finishfirstsoftware-com" {
  name        = "masters.kubernetes.finishfirstsoftware.com"
  vpc_id      = "${aws_vpc.kubernetes-finishfirstsoftware-com.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "kubernetes.finishfirstsoftware.com"
    Name              = "masters.kubernetes.finishfirstsoftware.com"
  }
}

resource "aws_security_group" "nodes-kubernetes-finishfirstsoftware-com" {
  name        = "nodes.kubernetes.finishfirstsoftware.com"
  vpc_id      = "${aws_vpc.kubernetes-finishfirstsoftware-com.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster = "kubernetes.finishfirstsoftware.com"
    Name              = "nodes.kubernetes.finishfirstsoftware.com"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"
  source_security_group_id = "${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-kubernetes-finishfirstsoftware-com.id}"
  source_security_group_id = "${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-kubernetes-finishfirstsoftware-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-finishfirstsoftware-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-kubernetes-finishfirstsoftware-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-kubernetes-finishfirstsoftware-com.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"
  source_security_group_id = "${aws_security_group.api-elb-kubernetes-finishfirstsoftware-com.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-kubernetes-finishfirstsoftware-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-finishfirstsoftware-com.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-finishfirstsoftware-com.id}"
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-finishfirstsoftware-com.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"
  source_security_group_id = "${aws_security_group.nodes-kubernetes-finishfirstsoftware-com.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-kubernetes-finishfirstsoftware-com.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "us-west-2b-kubernetes-finishfirstsoftware-com" {
  vpc_id            = "${aws_vpc.kubernetes-finishfirstsoftware-com.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "us-west-2b"

  tags = {
    KubernetesCluster                                          = "kubernetes.finishfirstsoftware.com"
    Name                                                       = "us-west-2b.kubernetes.finishfirstsoftware.com"
    "kubernetes.io/cluster/kubernetes.finishfirstsoftware.com" = "owned"
    "kubernetes.io/role/elb"                                   = "1"
  }
}


resource "aws_vpc_dhcp_options" "kubernetes-finishfirstsoftware-com" {
  domain_name         = "us-west-2.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster = "kubernetes.finishfirstsoftware.com"
    Name              = "kubernetes.finishfirstsoftware.com"
  }
}

resource "aws_vpc_dhcp_options_association" "kubernetes-finishfirstsoftware-com" {
  vpc_id          = "${aws_vpc.kubernetes-finishfirstsoftware-com.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.kubernetes-finishfirstsoftware-com.id}"
}

