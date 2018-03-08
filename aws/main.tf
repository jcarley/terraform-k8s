# us-west-2 xenial 16.04 LTS amd64 hvm:ebs-ssd 20180126 ami-79873901 hvm
# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "com.example.jcarley.deploy"
    key    = "k8s/state-store"
    region = "us-west-2"
  }
}

module "vpc" {
  source       = "modules/vpc"
  cluster_name = "${var.cluster_name}"
  aws_region   = "${var.aws_region}"
}
