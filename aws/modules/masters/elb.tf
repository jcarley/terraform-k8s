
resource "aws_elb" "api-loadbalancer" {
  name = "api-lb-${var.cluster_name}"

  listener = {
    instance_port     = 6443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-loadbalancer-secgroup.id}"]
  subnets         = ["${var.public_subnet_id}"]

  health_check = {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "${var.cluster_name}"
    Name              = "api.kubernetes.finishfirstsoftware.com"
  }
}

# resource "aws_subnet" "us-west-2b-kubernetes" {
#   vpc_id            = "${var.vpc_id}"
#   cidr_block        = "172.20.32.0/19"
#   availability_zone = "us-west-2b"
#
#   tags = "${merge(map(
#       "Name", "${var.cluster_name}.${var.base_domain}",
#       "kubernetes.io/cluster/${var.cluster_name}", "owned",
#       "KubernetesCluster", "${var.cluster_name}",
#       "kubernetes.io/role/elb", "1",
#     ), var.extra_tags)}"
# }

resource "aws_security_group" "api-loadbalancer-secgroup" {
  name        = "api-loadbalancer-secgroup"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster = "${var.cluster_name}"
    Name              = "api-elb.kubernetes.finishfirstsoftware.com"
  }
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-loadbalancer-secgroup.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-loadbalancer-secgroup.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${var.sg_masters_id}"
  source_security_group_id = "${aws_security_group.api-loadbalancer-secgroup.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

