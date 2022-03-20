# infra_region = "eu-central-1"

my_ip = "83.243.35.91/32"

vpc = {
    cidr = "11.0.0.0/16"
    subnets = {
        bastion = {
            cidr = "11.0.0.0/24"
        }
        jenkins_master = {
            cidr = "11.0.1.0/24"
        }
        jenkins_node = {
            cidr = "11.0.2.0/24"
        }
    }
}