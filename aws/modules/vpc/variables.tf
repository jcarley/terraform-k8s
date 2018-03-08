# Stack name and kubernetes.io/cluster/<Cluster ID> must match
variable "cluster_name" {
  default = "terraform_example"
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}

variable "vpc_cidr_block" {
  description = ""
  default = "10.0.0.0/16"
}

variable "private_subnet_cidr_block" {
  default = "10.0.0.0/19"
}

variable "public_subnet_cidr_block" {
  default = "10.0.128.0/20"
}

variable "base_domain" {
  default = "example.com"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "aws_availability_zone" {
  default = "us-west-2b"
}
