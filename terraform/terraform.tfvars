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
            has_nat = true
            is_using_nat = false
            nat_gw = ""
        }
        jenkins_node = {
            name_prefix = "node"
            az = "eu-central-1b"
            cidr = "11.0.3.0/24"
            is_public = false
            has_nat = false
            is_using_nat = true
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