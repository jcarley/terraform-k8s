variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

# Stack name and kubernetes.io/cluster/<Cluster ID> must match
variable "cluster_name" {
  default = "terraform_example"
}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}


