variable "ec2s_map" {
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

variable "subnet_ids_map" {
    type = map(string)
}

variable "security_group_ids_map" {
    type = map(string)
}

variable "ebs_instance" {
    type = string
}