
# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "terraform_example_elb"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  tags {
    "kubernetes.io/cluster/terraform_example" = "owned"
  }

  ingress {
    from_port   = 30902
    to_port     = 30902
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

  tags {
    "kubernetes.io/cluster/terraform_example" = "owned"
  }

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

  subnets         = ["${aws_subnet.public.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  # instances       = ["${aws_instance.master.id}","${aws_instance.node.*.id}"]

  tags {
    "kubernetes.io/cluster/terraform_example" = "owned"
  }

  listener {
    instance_port     = 30902
    instance_protocol = "http"
    lb_port           = 30902
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 6443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "master" {
  instance_type = "t2.micro"

  tags {
    Name = "k8s-master"
    "kubernetes.io/cluster/terraform_example" = "owned"
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
  subnet_id = "${aws_subnet.public.id}"

  iam_instance_profile = "${aws_iam_instance_profile.ec2-role.id}"

  depends_on = ["aws_internet_gateway.default"]

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

  provisioner "file" {
    source      = "templates/default.storageclass.yaml"
    destination = "/tmp/default.storageclass.yaml"
  }

  provisioner "file" {
    source      = "templates/network-policy.yaml"
    destination = "/tmp/network-policy.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-kubelet-hostname.sh",
      "/tmp/setup-kubelet-hostname.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/master_setup.sh",
      "/tmp/master_setup.sh ${var.discovery_token} ${aws_instance.master.public_ip} ${aws_elb.web.dns_name} ${aws_elb.web.name} ${var.aws_region}",
    ]
  }

}

resource "aws_instance" "node" {
  instance_type = "t2.micro"

  tags {
    Name = "k8s-node-${count.index}"
    "kubernetes.io/cluster/terraform_example" = "owned"
  }

  count = 3

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
  subnet_id = "${aws_subnet.public.id}"

  iam_instance_profile = "${aws_iam_instance_profile.ec2-role.id}"

  depends_on = ["aws_internet_gateway.default"]

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
    source      = "scripts/node_setup.sh"
    destination = "/tmp/node_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/node_setup.sh",
      "/tmp/node_setup.sh ${var.discovery_token} ${aws_instance.master.private_ip }",
    ]
  }
}

resource "null_resource" "finalsetup" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ~/.ssh/terraform ubuntu@${aws_instance.master.public_ip}:~/.kube/config ./kube-config"
  }
}
