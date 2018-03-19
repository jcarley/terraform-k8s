# us-west-2 xenial 16.04 LTS amd64 hvm:ebs-ssd 20180126 ami-79873901 hvm
# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
  alias      = "default"
  version    = "~> 1.11"
}

# terraform {
#   backend "s3" {
#     bucket = "com.example.jcarley.deploy"
#     key    = "k8s/state-store"
#     region = "us-west-2"
#   }
# }

module "aws-k8s" {
  source = "git::https://github.com/poseidon/typhoon//aws/container-linux/kubernetes?ref=v1.9.4"

  cluster_name = "${var.cluster_name}"

  # AWS
  dns_zone           = "kubernetes.finishfirstsoftware.com"
  dns_zone_id        = "Z17R4MQ510Q631"
  controller_count   = 1
  controller_type    = "t2.medium"
  worker_count       = 2
  worker_type        = "t2.small"
  ssh_authorized_key = "${file(var.public_key_path)}"

  # bootkube
  asset_dir  = "${var.home_dir}/.secrets/clusters/${var.cluster_name}"
}

