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



