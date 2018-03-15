
# Stack name and kubernetes.io/cluster/<Cluster ID> must match
variable "cluster_name" {
  default = "terraform_example"
}

variable "vpc_id" {}

variable "base_domain" {}

variable "sg_masters_id" {}

variable "public_subnet_id" {}

variable "extra_tags" {
  description = "Extra AWS tags to be applied to created resources."
  type        = "map"
  default     = {}
}
