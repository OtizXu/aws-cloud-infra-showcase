variable "name_prefix" { type = string }
variable "environment" { type = string }
variable "service_name" { type = string }
variable "cpu" { type = number, default = 256 }
variable "memory" { type = number, default = 512 }
variable "container_definitions" { type = string }
variable "desired_count" { type = number, default = 1 }
variable "private_subnet_ids" { type = list(string) }
variable "security_groups" { type = list(string) }
