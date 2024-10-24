output "vpc_id"{
    value = aws_vpc.main.id
}

# output "az_info" {
#     value =data.aws_availbility_zones.available
# }

# output "default_vpc_info"{
#     value = data.aws_vpc.default
# }

# output "main_route_table_info"{
#     value = data.aws_route_table.main
# }

output "public_subnet_ids"{
    value =aws_subnet_public[*].id
}

output "private_subnet_ids"{
    value =aws_subnet_private[*].id
}

output "database_subnet_ids"{
    value =aws_subnet_database[*].id
}

output "database_subnet_groupname"{
    value =aws_db_subnet_group.default.name
}

