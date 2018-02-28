output "address" {
  value = "${aws_instance.master.*.public_ip}"
}
