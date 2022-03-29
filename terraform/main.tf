# Terraform config
terraform {
  required_version = "1.1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.7.0"
    }

  }

  backend "s3" {
    bucket = "terraform-ppanter"
    key    = "terraform_013.tfstate"
    region = "eu-central-1"
  }
}

# AWS provider config
provider "aws" {
  region = "eu-central-1"
}

# VPC
module "vpc" {
  source = "./modules/vpc"
  cidr = var.vpc.cidr
  vpc_name_prefix = var.vpc.name_prefix
  subnets_map = var.vpc.subnets
}

# Security groups
module "security_group" {
  source = "./modules/security_group"
  security_groups = var.security_groups
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./modules/ec2"
  ec2s_map = var.ec2s
  subnet_ids_map = module.vpc.subnet_ids
  security_group_ids_map = module.security_group.security_group_ids
}

# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJzvAxVDYpP9JlVe3CTtf1rYdkmhHCdqolf/LFJ0kRO9FutFSnSiKJYumy5bZXeP5fNE6zrt2JSm7DJn/hyaRmxQyuCPqTJs4czo20whXLkmA6W/1xfZH6T62aPea4+eLRUw8Vk+2OZ2hyOzxiItCOyZMkA5rvdiOGcHq7TLKA0s4nHbuNMR+zC1Fwl8ECoG9PeuAdaDGH3OOMWtQ+CbxZrHEGtWXuA2XNrlxanfLplaWEuiL5aKAGyDPcRJ0ub5qezPfm37/tJM3V5dKw4xtZjR8QsdMVXFUpVCrHeYo8fV1E5WpMrfWf5M6AeMcfyY9pzKlaS4uzhMsbtQrxf7dJbov3HsNhYvRhM+gAYXTv+hDMIsbCuCnhJLGS0zIyyk7muUzgy+jL+Ij/U0WLb3mSClpgk0uX7ekK7boHmJlZmHskvlW9gvbKw1vz20B5zmhE0PNtjgMbdKn8MkbVSErXKPczBVQ7zhM1Ll+2/DIlmloKUXaPyTMVk6CJnG39H4c= ppanter@DESKTOP-5OOPS6E"
# }

# resource "aws_volume_attachment" "jenkins_master_ebs_att" {
#   device_name = "/dev/sdf"
#   volume_id   = "vol-090d8ed13914dd4bf"
#   instance_id = aws_instance.jenkins_master_ec2.id
#   stop_instance_before_detaching = true
# }