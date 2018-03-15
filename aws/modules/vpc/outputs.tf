output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "sg_masters_id" {
  value = "${aws_security_group.masters.id}"
}

output "public_subnet_id" {
  value = "${aws_subnet.public_subnet.id}"
}


