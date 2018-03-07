output "cluster_name" {
  value = "kubernetes.example.com"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-kubernetes-example-com.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-kubernetes-example-com.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-kubernetes-example-com.name}"
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-kubernetes-example-com.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.us-west-2b-kubernetes-example-com.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-kubernetes-example-com.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-kubernetes-example-com.name}"
}

output "region" {
  value = "us-west-2"
}

output "vpc_id" {
  value = "${aws_vpc.kubernetes-example-com.id}"
}


