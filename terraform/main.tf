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
  region = "eu-north-1"
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
  ebs_instance = var.ebs_instance
}

module "lb" {
  source = "./modules/lb"
  name_prefix = var.lb.name_prefix
  private_port = var.lb.private_port
  public_port = var.lb.public_port
  load_balancer_type = var.lb.load_balancer_type
  log_bucket = var.lb.log_bucket
  vpc_id = module.vpc.vpc_id
  subnets = [for subnet in var.lb.subnets: module.vpc.subnet_ids[subnet]]
  security_groups = [for group in var.lb.security_groups: module.security_group.security_group_ids[group]]
  tarrget_instance_id = module.ec2.ec2s[var.lb.target_instance].id
}