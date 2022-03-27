variable vpc_id {
    description = "VPC id"
    type = string
}

variable security_groups {
    description = "Security groups configuration"
    type = map(object({
        name_prefix = string
        ingress_port = number
        ingress_cidr_blocks = string
    }))
}