terraform = {
  required_version = ">= 0.9.3"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_autoscaling_attachment" "master-us-west-2b-masters-kubernetes-example-com" {
  elb                    = "${aws_elb.api-kubernetes-example-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-us-west-2b-masters-kubernetes-example-com.id}"
}

resource "aws_autoscaling_group" "master-us-west-2b-masters-kubernetes-example-com" {
  name                 = "master-us-west-2b.masters.kubernetes.example.com"
  launch_configuration = "${aws_launch_configuration.master-us-west-2b-masters-kubernetes-example-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.us-west-2b-kubernetes-example-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "kubernetes.example.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-west-2b.masters.kubernetes.example.com"
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

resource "aws_autoscaling_group" "nodes-kubernetes-example-com" {
  name                 = "nodes.kubernetes.example.com"
  launch_configuration = "${aws_launch_configuration.nodes-kubernetes-example-com.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.us-west-2b-kubernetes-example-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "kubernetes.example.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.kubernetes.example.com"
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

resource "aws_ebs_volume" "b-etcd-events-kubernetes-example-com" {
  availability_zone = "us-west-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "kubernetes.example.com"
    Name                 = "b.etcd-events.kubernetes.example.com"
    "k8s.io/etcd/events" = "b/b"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "b-etcd-main-kubernetes-example-com" {
  availability_zone = "us-west-2b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "kubernetes.example.com"
    Name                 = "b.etcd-main.kubernetes.example.com"
    "k8s.io/etcd/main"   = "b/b"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_elb" "api-kubernetes-example-com" {
  name = "api-kubernetes-example-bgjn7a"

  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-kubernetes-example-com.id}"]
  subnets         = ["${aws_subnet.us-west-2b-kubernetes-example-com.id}"]

  health_check = {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "kubernetes.example.com"
    Name              = "api.kubernetes.example.com"
  }
}

resource "aws_iam_instance_profile" "masters-kubernetes-example-com" {
  name = "masters.kubernetes.example.com"
  role = "${aws_iam_role.masters-kubernetes-example-com.name}"
}

resource "aws_iam_instance_profile" "nodes-kubernetes-example-com" {
  name = "nodes.kubernetes.example.com"
  role = "${aws_iam_role.nodes-kubernetes-example-com.name}"
}

resource "aws_iam_role" "masters-kubernetes-example-com" {
  name               = "masters.kubernetes.example.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.kubernetes.example.com_policy")}"
}

resource "aws_iam_role" "nodes-kubernetes-example-com" {
  name               = "nodes.kubernetes.example.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.kubernetes.example.com_policy")}"
}

resource "aws_iam_role_policy" "masters-kubernetes-example-com" {
  name   = "masters.kubernetes.example.com"
  role   = "${aws_iam_role.masters-kubernetes-example-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.kubernetes.example.com_policy")}"
}

resource "aws_iam_role_policy" "nodes-kubernetes-example-com" {
  name   = "nodes.kubernetes.example.com"
  role   = "${aws_iam_role.nodes-kubernetes-example-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.kubernetes.example.com_policy")}"
}

resource "aws_internet_gateway" "kubernetes-example-com" {
  vpc_id = "${aws_vpc.kubernetes-example-com.id}"

  tags = {
    KubernetesCluster = "kubernetes.example.com"
    Name              = "kubernetes.example.com"
  }
}

resource "aws_key_pair" "kubernetes-kubernetes-example-com-cc080831712565bd229369c229dd288a" {
  key_name   = "kubernetes.kubernetes.example.com-cc:08:08:31:71:25:65:bd:22:93:69:c2:29:dd:28:8a"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.kubernetes.example.com-cc080831712565bd229369c229dd288a_public_key")}"
}

