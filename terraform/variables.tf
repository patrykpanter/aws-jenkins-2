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
        cidr = string
        subnets = map(object({
            cidr = string
            public_ip = bool
            nat = bool
        }))
    })
}

