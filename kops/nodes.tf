resource "aws_launch_configuration" "nodes-kubernetes-example-com" {
  name_prefix                 = "nodes.kubernetes.example.com-"
  image_id                    = "ami-485eef30"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.kubernetes-kubernetes-example-com-cc080831712565bd229369c229dd288a.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-kubernetes-example-com.id}"
  security_groups             = ["${aws_security_group.nodes-kubernetes-example-com.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.kubernetes.example.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

