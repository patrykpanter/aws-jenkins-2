# infra_region = "eu-central-1"

my_ip = "0.0.0.0/0"

vpc = {
    cidr = "11.0.0.0/16"
    subnets = {
        bastion = {
            cidr = "11.0.0.0/24"
            public_ip = true
            nat = false
        }
        jenkins_master = {
            cidr = "11.0.1.0/24"
            public_ip = true
            nat = true
        }
        jenkins_node = {
            cidr = "11.0.3.0/24"
            public_ip = false
            nat = false
        }
    }
}