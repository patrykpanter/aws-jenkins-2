# variable infra_region {
#     description = "Region where infrastructure is created"
#     type = string
# }

variable my_ip {
    description = "My IP used to limit access to network"
    type = string
}

variable vpc {
    description = "Network configuration"
    type = object({
        name_prefix = string
        cidr = string
        subnets = map(object({
            name_prefix = string
            az = string
            cidr = string
            is_public = bool
            has_nat = bool
            is_using_nat = bool
            nat_gw = string
        }))
    })
}

variable security_groups {
    description = "Security groups configuration"
    type = map(object({
        name_prefix = string
        ingress_port = number
        ingress_cidr_blocks = string
    }))
}

variable ec2s {
    description = "EC2 hosts configuration"
    type = map(object({
        subnet = string
        security_groups = set(string)
        packer_ami_prefix = string
        packer_ami_owner = string
        name_prefix = string
        instance_type = string
        availability_zone = string
        is_private_ip = bool
        private_ip = string
    }))
}

variable "ebs_instance" {
    type = string
}

variable "lb" {
    type = object({
        name_prefix = string
        load_balancer_type = string
        log_bucket = string
        subnets = set(string)
        security_groups = set(string)
    })
}