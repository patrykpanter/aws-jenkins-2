# infra_region = "eu-central-1"

my_ip = "0.0.0.0"

vpc = {
    name_prefix = "jenkins"
    cidr = "11.0.0.0/16"
    subnets = {
        bastion = {
            name_prefix = "bastion"
            az = "eu-central-1b"
            cidr = "11.0.1.0/24"
            is_public = true
            has_nat = false
            is_using_nat = false
            nat_gw = ""
        }
        jenkins_master = {
            name_prefix = "master"
            az = "eu-central-1b"
            cidr = "11.0.2.0/24"
            is_public = true
            has_nat = false
            is_using_nat = false
            nat_gw = ""
        }
        jenkins_node = {
            name_prefix = "node"
            az = "eu-central-1b"
            cidr = "11.0.3.0/24"
            is_public = false
            has_nat = false
            is_using_nat = false
            nat_gw = "jenkins_master"
        }
    }
}

security_groups = {
    ssh = {
        name_prefix = "ssh-public"
        ingress_port = 22
        ingress_cidr_blocks = "0.0.0.0/0"
    }
    ssh_jenkins_node = {
        name_prefix = "ssh-jenkins-node"
        ingress_port = 22
        ingress_cidr_blocks = "11.0.2.0/24"
    }    
    ssh_bastion = {
        name_prefix = "ssh-bastion"
        ingress_port = 22
        ingress_cidr_blocks = "11.0.1.0/24"
    }
    http_jenkins_master = {
        name_prefix = "http-jenkins-master"
        ingress_port = 8080
        ingress_cidr_blocks = "0.0.0.0/0"
    }
}

ec2s = {
    bastion = {
        subnet = "bastion"
        security_groups = ["ssh"]
        packer_ami_prefix = "packer-bastion-*"
        packer_ami_owner = "699942661490"
        name_prefix = "jenkins-bastion"
        instance_type = "t2.micro"
        availability_zone = "eu-central-1b"
        is_private_ip = false
        private_ip = ""
    }
    jenkins_master = {
        subnet = "jenkins_master"
        security_groups = ["ssh_bastion", "http_jenkins_master"]
        packer_ami_prefix = "packer-jenkins-master-*"
        packer_ami_owner = "699942661490"
        name_prefix = "jenkins-master"
        instance_type = "t2.micro"
        availability_zone = "eu-central-1b"
        is_private_ip = false
        private_ip = ""
    }
    jenkins_node = {
        subnet = "jenkins_node"
        security_groups = ["ssh_bastion", "ssh_jenkins_node"]
        packer_ami_prefix = "packer-jenkins-node-*"
        packer_ami_owner = "699942661490"
        name_prefix = "jenkins-node"
        instance_type = "t2.micro"
        availability_zone = "eu-central-1b"
        is_private_ip = true
        private_ip = "11.0.2.1/32"
    }
}

ebs_instance = "jenkins_master"