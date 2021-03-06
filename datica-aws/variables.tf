variable "name" {
  description = "name to pass to Name tag"
  default = "terraform-jcarley"
}

variable "count" {
  default = 2
}

variable "instance_type" {
  description = "type of EC2 instance to provision."
  default = "t2.micro"
}

variable "ebs_device_name" {
  description = "the device name for the ebs volume"
  default = {
    "git" = "/dev/xvdg"
    "bitbucket" = "/dev/xvdh"
  }
}

variable "ebs_volume_type" {
  default = "gp2"
}

variable "ebs_volume_size" {
  default = 5
}


variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "terraform-jcarley"
}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

# Ubuntu Xenial 16.04 LTS (x64) hvm:ebs-ssd
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-1b791862"
    us-east-1 = "ami-66506c1c"
    us-west-1 = "ami-07585467"
    us-west-2 = "ami-79873901"
  }
}

