variable "cidr" {
    type = string
}

variable "vpc_name_prefix" {
    type = string
}

variable "subnets_map" {
    type = map(object({
            name_prefix = string
            az = string
            cidr = string
            is_public = bool
            has_nat = bool
            is_using_nat = bool
            nat_gw = string
        }))
}