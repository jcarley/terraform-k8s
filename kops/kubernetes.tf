provider "aws" {
  region = "us-west-2"
}

resource "aws_autoscaling_attachment" "master-us-west-2b-masters-kubernetes-finishfirstsoftware-com" {
  elb                    = "${aws_elb.api-kubernetes-finishfirstsoftware-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-us-west-2b-masters-kubernetes-finishfirstsoftware-com.id}"
}

resource "aws_autoscaling_group" "master-us-west-2b-masters-kubernetes-finishfirstsoftware-com" {
  name                 = "master-us-west-2b.masters.kubernetes.finishfirstsoftware.com"
  launch_configuration = "${aws_launch_configuration.master-us-west-2b-masters-kubernetes-finishfirstsoftware-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.us-west-2b-kubernetes-finishfirstsoftware-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "kubernetes.finishfirstsoftware.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-west-2b.masters.kubernetes.finishfirstsoftware.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-west-2b"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-kubernetes-finishfirstsoftware-com" {
  name                 = "nodes.kubernetes.finishfirstsoftware.com"
  launch_configuration = "${aws_launch_configuration.nodes-kubernetes-finishfirstsoftware-com.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.us-west-2b-kubernetes-finishfirstsoftware-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "kubernetes.finishfirstsoftware.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.kubernetes.finishfirstsoftware.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "b-etcd-events-kubernetes-finishfirstsoftware-com" {
  availability_zone = "us-west-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "kubernetes.finishfirstsoftware.com"
    Name                 = "b.etcd-events.kubernetes.finishfirstsoftware.com"
    "k8s.io/etcd/events" = "b/b"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "b-etcd-main-kubernetes-finishfirstsoftware-com" {
  availability_zone = "us-west-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "kubernetes.finishfirstsoftware.com"
    Name                 = "b.etcd-main.kubernetes.finishfirstsoftware.com"
    "k8s.io/etcd/main"   = "b/b"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_elb" "api-kubernetes-finishfirstsoftware-com" {
  name = "api-kubernetes-finishfirs-bgjn7a"

  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-kubernetes-finishfirstsoftware-com.id}"]
  subnets         = ["${aws_subnet.us-west-2b-kubernetes-finishfirstsoftware-com.id}"]

  health_check = {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "kubernetes.finishfirstsoftware.com"
    Name              = "api.kubernetes.finishfirstsoftware.com"
  }
}

resource "aws_iam_instance_profile" "masters-kubernetes-finishfirstsoftware-com" {
  name = "masters.kubernetes.finishfirstsoftware.com"
  role = "${aws_iam_role.masters-kubernetes-finishfirstsoftware-com.name}"
}

resource "aws_iam_instance_profile" "nodes-kubernetes-finishfirstsoftware-com" {
  name = "nodes.kubernetes.finishfirstsoftware.com"
  role = "${aws_iam_role.nodes-kubernetes-finishfirstsoftware-com.name}"
}

resource "aws_iam_role" "masters-kubernetes-finishfirstsoftware-com" {
  name               = "masters.kubernetes.finishfirstsoftware.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.kubernetes.finishfirstsoftware.com_policy")}"
}

resource "aws_iam_role" "nodes-kubernetes-finishfirstsoftware-com" {
  name               = "nodes.kubernetes.finishfirstsoftware.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.kubernetes.finishfirstsoftware.com_policy")}"
}

resource "aws_iam_role_policy" "masters-kubernetes-finishfirstsoftware-com" {
  name   = "masters.kubernetes.finishfirstsoftware.com"
  role   = "${aws_iam_role.masters-kubernetes-finishfirstsoftware-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.kubernetes.finishfirstsoftware.com_policy")}"
}

resource "aws_iam_role_policy" "nodes-kubernetes-finishfirstsoftware-com" {
  name   = "nodes.kubernetes.finishfirstsoftware.com"
  role   = "${aws_iam_role.nodes-kubernetes-finishfirstsoftware-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.kubernetes.finishfirstsoftware.com_policy")}"
}

resource "aws_internet_gateway" "kubernetes-finishfirstsoftware-com" {
  vpc_id = "${aws_vpc.kubernetes-finishfirstsoftware-com.id}"

  tags = {
    KubernetesCluster = "kubernetes.finishfirstsoftware.com"
    Name              = "kubernetes.finishfirstsoftware.com"
  }
}

resource "aws_key_pair" "kubernetes-kubernetes-finishfirstsoftware-com-cc080831712565bd229369c229dd288a" {
  key_name   = "kubernetes.kubernetes.finishfirstsoftware.com-cc:08:08:31:71:25:65:bd:22:93:69:c2:29:dd:28:8a"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.kubernetes.finishfirstsoftware.com-cc080831712565bd229369c229dd288a_public_key")}"
}


resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.kubernetes-finishfirstsoftware-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.kubernetes-finishfirstsoftware-com.id}"
}

resource "aws_route53_record" "api-kubernetes-finishfirstsoftware-com" {
  name = "api.kubernetes.finishfirstsoftware.com"
  type = "A"

  alias = {
    name                   = "${aws_elb.api-kubernetes-finishfirstsoftware-com.dns_name}"
    zone_id                = "${aws_elb.api-kubernetes-finishfirstsoftware-com.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/Z17R4MQ510Q631"
}

resource "aws_route_table" "kubernetes-finishfirstsoftware-com" {
  vpc_id = "${aws_vpc.kubernetes-finishfirstsoftware-com.id}"

  tags = {
    KubernetesCluster = "kubernetes.finishfirstsoftware.com"
    Name              = "kubernetes.finishfirstsoftware.com"
  }
}

resource "aws_route_table_association" "us-west-2b-kubernetes-finishfirstsoftware-com" {
  subnet_id      = "${aws_subnet.us-west-2b-kubernetes-finishfirstsoftware-com.id}"
  route_table_id = "${aws_route_table.kubernetes-finishfirstsoftware-com.id}"
}

terraform = {
  required_version = ">= 0.9.3"
}
