# us-west-2 xenial 16.04 LTS amd64 hvm:ebs-ssd 20180126 ami-79873901 hvm
# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# create a role so the aws instances can access aws resources
resource "aws_iam_instance_profile" "ec2-role" {
  name = "${var.role_name}"
  role = "${aws_iam_role.ec2-role.name}"
  path = "${var.role_path}"
}

resource "aws_iam_role" "ec2-role" {
  name                  = "${var.role_name}"
  path                  = "${var.role_path}"
  force_detach_policies = "false"
  assume_role_policy    = "${data.aws_iam_policy_document.ec2-assume-role.json}"
}

data "aws_iam_policy_document" "ec2-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = "${length(var.policy_arn)}"
  role       = "${aws_iam_role.ec2-role.name}"
  policy_arn = "${var.policy_arn[count.index]}"
}


# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "terraform_example_elb"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30902
    to_port     = 30902
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH
resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "terraform-example-elb"

  subnets         = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  # instances       = ["${aws_instance.master.id}","${aws_instance.node.*.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 30902
    instance_protocol = "http"
    lb_port           = 30902
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 3000
    lb_protocol       = "http"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "master" {
  instance_type = "t2.micro"

  tags {
    Name = "master"
  }

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.default.id}"

  iam_instance_profile = "${aws_iam_instance_profile.ec2-role.id}"

  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    user = "ubuntu"
    type = "ssh"
    agent = true
    private_key = "${file(var.private_key_path)}"
    timeout = "2m"
  }

  provisioner "file" {
    source      = "scripts/master_setup.sh"
    destination = "/tmp/master_setup.sh"
  }

  provisioner "file" {
    source      = "scripts/setup-kubelet-hostname.sh"
    destination = "/tmp/setup-kubelet-hostname.sh"
  }

  provisioner "file" {
    source      = "templates/dashboard.yaml"
    destination = "/tmp/dashboard.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/master_setup.sh",
      "/tmp/master_setup.sh ${var.discovery_token} ${aws_instance.master.public_ip} ${aws_elb.web.dns_name} ${aws_elb.web.name} ${var.aws_region}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-kubelet-hostname.sh",
      "/tmp/setup-kubelet-hostname.sh",
    ]
  }
}

# resource "aws_instance" "node" {
#   instance_type = "t2.micro"
#
#   tags {
#     Name = "node-${count.index}"
#   }
#
#   count = 3
#
#   # Lookup the correct AMI based on the region
#   # we specified
#   ami = "${lookup(var.aws_amis, var.aws_region)}"
#
#   # The name of our SSH keypair we created above.
#   key_name = "${aws_key_pair.auth.id}"
#
#   # Our Security group to allow HTTP and SSH access
#   vpc_security_group_ids = ["${aws_security_group.default.id}"]
#
#   # We're going to launch into the same subnet as our ELB. In a production
#   # environment it's more common to have a separate private subnet for
#   # backend instances.
#   subnet_id = "${aws_subnet.default.id}"
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
#     source      = "node_setup.sh"
#     destination = "/tmp/node_setup.sh"
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/node_setup.sh",
#       "/tmp/node_setup.sh ${var.discovery_token} ${aws_instance.master.public_ip}",
#     ]
#   }
# }

