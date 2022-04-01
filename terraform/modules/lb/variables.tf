variable "name_prefix" {
    type = string
}

variable "load_balancer_type" {
    type = string
}
variable "subnets" {
    type = set(string)
}

variable "security_groups" {
    type = set(string)
}

variable "log_bucket" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "tarrget_instance_id" {
    type = string
}

variable "public_port" {
    type = string
}

variable "private_port" {
    type = string
}