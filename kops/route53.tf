resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.kubernetes-example-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.kubernetes-example-com.id}"
}

resource "aws_route53_record" "api-kubernetes-example-com" {
  name = "api.kubernetes.example.com"
  type = "A"

  alias = {
    name                   = "${aws_elb.api-kubernetes-example-com.dns_name}"
    zone_id                = "${aws_elb.api-kubernetes-example-com.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/Z17R4MQ510Q631"
}

resource "aws_route_table" "kubernetes-example-com" {
  vpc_id = "${aws_vpc.kubernetes-example-com.id}"

  tags = {
    KubernetesCluster = "kubernetes.example.com"
    Name              = "kubernetes.example.com"
  }
}

resource "aws_route_table_association" "us-west-2b-kubernetes-example-com" {
  subnet_id      = "${aws_subnet.us-west-2b-kubernetes-example-com.id}"
  route_table_id = "${aws_route_table.kubernetes-example-com.id}"
}

