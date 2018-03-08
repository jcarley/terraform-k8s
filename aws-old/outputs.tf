output "elb_address" {
  value = "${aws_elb.web.dns_name}"
}

output "master_address" {
  value = "${aws_instance.master.*.public_ip}"
}

output "discovery_token" {
  value = "${var.discovery_token}"
}

output "nodes_address" {
  value = "${aws_instance.node.*.public_ip}"
}

