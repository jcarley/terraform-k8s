# resource "aws_network_interface" "bastion_ni" {
#   subnet_id = "${aws_subnet.public_subnet.id}"
#   private_ips = ["10.0.128.5"]
#   security_groups = ["${aws_security_group.bastion_sg.id}"]
# }


# resource "aws_security_group" "bastion_sg" {
#   name        = "allow_bastion_ssh"
#   description = "Enable SSH access via port 22"
#   vpc_id      = "${aws_vpc.default.id}"
#
#   # for this stack we are allowing ssh access from all locations
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   # outbound internet access
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# setup a bastion
# resource "aws_instance" "bastion" {
#   instance_type = "${var.bastion_instance_type}"
#
#   tags = "${merge(map(
#       "Name", "${var.cluster_name}_bastion_host",
#     ), var.extra_tags)}"
#
#   # Lookup the correct AMI based on the region
#   # we specified
#   ami = "${lookup(var.aws_amis, var.aws_region)}"
#
#   # The name of our SSH keypair we created above.
#   key_name = "${var.key_pair_id}"
#
#   # Our Security group to allow HTTP and SSH access
#   vpc_security_group_ids = ["${aws_security_group.bastion_sg.id}"]
#
#   # We're going to launch into the same subnet as our ELB. In a production
#   # environment it's more common to have a separate private subnet for
#   # backend instances.
#
#   # iam_instance_profile = "${aws_iam_instance_profile.ec2-role.id}"
#
#   subnet_id = "${aws_subnet.public_subnet.id}"
#
#   associate_public_ip_address = true
#
#   # network_interface {
#   #   device_index          = 0
#   #   network_interface_id  = "${aws_network_interface.bastion_ni.id}"
#   # }
#
#   # user_data = "${file("${path.module}/scripts/bastion.user_data")}"
#
#   # The connection block tells our provisioner how to
#   # communicate with the resource (instance)
#   connection {
#     user = "ubuntu"
#     type = "ssh"
#     agent = true
#     private_key = "${file(var.private_key_path)}"
#     timeout = "2m"
#   }
#
#   provisioner "file" {
#     source      = "${path.module}/scripts/banner_message.txt"
#     destination = "/tmp/banner_message.txt"
#   }
#
#   provisioner "file" {
#     source      = "${path.module}/scripts/bastion.sh"
#     destination = "/tmp/bastion.sh"
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/bastion.sh",
#       "/tmp/bastion.sh",
#     ]
#   }
# }

