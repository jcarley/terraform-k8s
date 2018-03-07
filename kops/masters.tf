resource "aws_launch_configuration" "master-us-west-2b-masters-kubernetes-example-com" {
  name_prefix                 = "master-us-west-2b.masters.kubernetes.example.com-"
  image_id                    = "ami-485eef30"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.auth.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-kubernetes-example-com.id}"
  security_groups             = ["${aws_security_group.masters-kubernetes-example-com.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-west-2b.masters.kubernetes.example.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

