packer {
  required_plugins {
    amazon = {
      version = " >= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "packer-jenkins-node"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t3.micro"
  region        = "eu-north-1"
  source_ami    = "ami-092cce4a19b438926"
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    host_alias    = "jenkins_node"
    ansible_env_vars = [ "ANSIBLE_CONFIG=ansible.cfg" ]
  }
}