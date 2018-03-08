# us-west-2 xenial 16.04 LTS amd64 hvm:ebs-ssd 20180126 ami-79873901 hvm
# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

