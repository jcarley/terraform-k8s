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

variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "key_pair_id" {
}

variable "private_key_path" {
}


# TODO: These should really be moved out at a later time.  Leaving
#       in here until further along

# Ubuntu Xenial 16.04 LTS (x64) hvm:ebs-ssd
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-1b791862"
    us-east-1 = "ami-66506c1c"
    us-west-1 = "ami-07585467"
    us-west-2 = "ami-79873901"
  }
}
