output security_group_ids {
    value = {for i, v in aws_security_group.security_group: i => v.id}
}