output "cluster_name" {
  value = "kubernetes.finishfirstsoftware.com"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-kubernetes-finishfirstsoftware-com.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-kubernetes-finishfirstsoftware-com.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-kubernetes-finishfirstsoftware-com.name}"
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-kubernetes-finishfirstsoftware-com.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.us-west-2b-kubernetes-finishfirstsoftware-com.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-kubernetes-finishfirstsoftware-com.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-kubernetes-finishfirstsoftware-com.name}"
}

output "region" {
  value = "us-west-2"
}

output "vpc_id" {
  value = "${aws_vpc.kubernetes-finishfirstsoftware-com.id}"
}


